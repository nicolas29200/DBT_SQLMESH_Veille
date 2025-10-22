#!/usr/bin/env python3
"""
dbt to SQLMesh Conversion Tool

This tool converts a dbt project to a SQLMesh project, handling:
- dbt_project.yml -> config.yaml
- models/*.sql -> models/*.sql with MODEL DDL
- schema.yml -> embedded model configurations
- Dependencies and lineage preservation
"""

import os
import sys
import yaml
import json
import argparse
import shutil
from pathlib import Path
from typing import Dict, List, Any, Optional
import re


class DBTToSQLMeshConverter:
    def __init__(self, dbt_project_path: str, output_path: str):
        self.dbt_project_path = Path(dbt_project_path)
        self.output_path = Path(output_path)
        self.dbt_project_config = {}
        self.models_config = {}
        self.model_dependencies = {}
        
    def load_dbt_project(self):
        """Load and parse dbt_project.yml"""
        dbt_project_file = self.dbt_project_path / "dbt_project.yml"
        if not dbt_project_file.exists():
            raise FileNotFoundError(f"dbt_project.yml not found in {self.dbt_project_path}")
        
        with open(dbt_project_file, 'r') as f:
            self.dbt_project_config = yaml.safe_load(f)
    
    def load_schema_files(self):
        """Load and parse schema.yml files"""
        schema_files = list(self.dbt_project_path.rglob("**/schema.yml")) + \
                     list(self.dbt_project_path.rglob("**/_*.yml"))
        
        for schema_file in schema_files:
            with open(schema_file, 'r') as f:
                schema_config = yaml.safe_load(f)
                if 'models' in schema_config:
                    for model in schema_config['models']:
                        model_name = model.get('name')
                        if model_name:
                            self.models_config[model_name] = model
    
    def extract_model_dependencies(self, sql_content: str) -> List[str]:
        """Extract model dependencies from SQL content"""
        dependencies = []
        
        # Look for {{ ref('model_name') }} patterns
        ref_pattern = r"{{\s*ref\s*\(\s*['\"]([^'\"]+)['\"]\s*\)\s*}}"
        ref_matches = re.findall(ref_pattern, sql_content)
        dependencies.extend(ref_matches)
        
        # Look for {{ source('source_name', 'table_name') }} patterns
        source_pattern = r"{{\s*source\s*\(\s*['\"]([^'\"]+)['\"]\s*,\s*['\"]([^'\"]+)['\"]\s*\)\s*}}"
        source_matches = re.findall(source_pattern, sql_content)
        for source_name, table_name in source_matches:
            dependencies.append(f"{source_name}.{table_name}")
        
        return dependencies
    
    def convert_materialization_to_kind(self, materialization: str) -> str:
        """Convert dbt materialization to SQLMesh model kind"""
        mapping = {
            'table': 'FULL',
            'view': 'VIEW',
            'incremental': 'INCREMENTAL_BY_TIME_RANGE',  # Default, may need adjustment
            'ephemeral': 'EMBEDDED'
        }
        return mapping.get(materialization, 'VIEW')
    
    def generate_model_ddl(self, model_name: str, model_config: Dict[str, Any], 
                          materialization: str = 'view') -> str:
        """Generate SQLMesh MODEL DDL from dbt model configuration"""
        
        # Get the schema from dbt project config
        schema_name = self.dbt_project_config.get('model-paths', ['models'])[0]
        full_model_name = f"{schema_name}.{model_name}"
        
        # Convert materialization to SQLMesh kind
        kind = self.convert_materialization_to_kind(materialization)
        
        # Build MODEL DDL
        ddl_parts = [
            f"name {full_model_name}",
            f"kind {kind}"
        ]
        
        # Add incremental configuration if needed
        if kind == 'INCREMENTAL_BY_TIME_RANGE':
            # Try to find time column from model config
            time_column = model_config.get('time_column', 'created_at')
            ddl_parts.append(f"kind INCREMENTAL_BY_TIME_RANGE ( time_column {time_column} )")
        elif kind == 'INCREMENTAL_BY_UNIQUE_KEY':
            unique_key = model_config.get('unique_key', 'id')
            ddl_parts.append(f"kind INCREMENTAL_BY_UNIQUE_KEY ( unique_key {unique_key} )")
        
        # Add owner if available
        if 'owner' in model_config:
            ddl_parts.append(f"owner '{model_config['owner']}'")
        
        # Add cron if available
        if 'cron' in model_config:
            ddl_parts.append(f"cron '{model_config['cron']}'")
        
        # Construct the full MODEL statement
        if kind in ['INCREMENTAL_BY_TIME_RANGE', 'INCREMENTAL_BY_UNIQUE_KEY']:
            return f"MODEL (\n  {ddl_parts[0]},\n  {ddl_parts[1]}\n);"
        else:
            return f"MODEL (\n  {ddl_parts[0]},\n  {ddl_parts[1]}\n);"
    
    def convert_sql_model(self, sql_file: Path, output_file: Path):
        """Convert a dbt SQL model to SQLMesh format"""
        with open(sql_file, 'r') as f:
            sql_content = f.read()
        
        # Extract model name from file path
        model_name = sql_file.stem
        
        # Get model configuration
        model_config = self.models_config.get(model_name, {})
        
        # Determine materialization
        materialization = model_config.get('materialized', 'view')
        if 'config' in model_config and 'materialized' in model_config['config']:
            materialization = model_config['config']['materialized']
        
        # Extract dependencies
        dependencies = self.extract_model_dependencies(sql_content)
        self.model_dependencies[model_name] = dependencies
        
        # Generate MODEL DDL
        model_ddl = self.generate_model_ddl(model_name, model_config, materialization)
        
        # Convert dbt Jinja to SQLMesh format (basic conversion)
        converted_sql = self.convert_jinja_syntax(sql_content)
        
        # Combine MODEL DDL with SQL
        full_sql = f"{model_ddl}\n\n{converted_sql}"
        
        # Write to output file
        os.makedirs(output_file.parent, exist_ok=True)
        with open(output_file, 'w') as f:
            f.write(full_sql)
    
    def convert_jinja_syntax(self, sql_content: str) -> str:
        """Convert dbt Jinja syntax to SQLMesh compatible format"""
        # Convert {{ ref('model') }} to model references
        sql_content = re.sub(
            r"{{\s*ref\s*\(\s*['\"]([^'\"]+)['\"]\s*\)\s*}}",
            r"\1",
            sql_content
        )
        
        # Convert {{ source('source', 'table') }} to source references
        sql_content = re.sub(
            r"{{\s*source\s*\(\s*['\"]([^'\"]+)['\"]\s*,\s*['\"]([^'\"]+)['\"]\s*\)\s*}}",
            r"\1.\2",
            sql_content
        )
        
        # Remove dbt-specific macros (basic handling)
        sql_content = re.sub(r"{{\s*config\s*\([^}]*\)\s*}}", "", sql_content)
        
        return sql_content.strip()
    
    def generate_sqlmesh_config(self) -> Dict[str, Any]:
        """Generate SQLMesh config.yaml from dbt configuration"""
        
        # Default SQLMesh configuration
        config = {
            'gateways': {
                'local': {
                    'connection': {
                        'type': 'duckdb',
                        'database': 'db.db'
                    }
                }
            },
            'default_gateway': 'local',
            'model_defaults': {
                'dialect': 'duckdb',
                'start': '2024-01-01'
            }
        }
        
        # Try to infer dialect from dbt profile
        profile_name = self.dbt_project_config.get('profile')
        if profile_name:
            # This is a simplified mapping - in practice, you'd read profiles.yml
            config['model_defaults']['dialect'] = 'snowflake'  # or other based on profile
        
        return config
    
    def copy_seed_files(self):
        """Copy seed files from dbt to SQLMesh"""
        dbt_seeds_path = self.dbt_project_path / "seeds"
        if dbt_seeds_path.exists():
            sqlmesh_seeds_path = self.output_path / "seeds"
            shutil.copytree(dbt_seeds_path, sqlmesh_seeds_path, dirs_exist_ok=True)
    
    def convert_project(self):
        """Main conversion process"""
        print(f"Converting dbt project from {self.dbt_project_path} to {self.output_path}")
        
        # Load dbt project configuration
        self.load_dbt_project()
        self.load_schema_files()
        
        # Create output directory structure
        self.output_path.mkdir(parents=True, exist_ok=True)
        (self.output_path / "models").mkdir(exist_ok=True)
        (self.output_path / "audits").mkdir(exist_ok=True)
        (self.output_path / "macros").mkdir(exist_ok=True)
        
        # Generate SQLMesh config.yaml
        sqlmesh_config = self.generate_sqlmesh_config()
        with open(self.output_path / "config.yaml", 'w') as f:
            yaml.dump(sqlmesh_config, f, default_flow_style=False)
        
        # Convert models
        models_path = self.dbt_project_path / "models"
        if models_path.exists():
            for sql_file in models_path.rglob("*.sql"):
                # Calculate relative path to preserve directory structure
                rel_path = sql_file.relative_to(models_path)
                output_file = self.output_path / "models" / rel_path
                self.convert_sql_model(sql_file, output_file)
        
        # Copy seed files
        self.copy_seed_files()
        
        # Copy macros (if any)
        dbt_macros_path = self.dbt_project_path / "macros"
        if dbt_macros_path.exists():
            sqlmesh_macros_path = self.output_path / "macros"
            shutil.copytree(dbt_macros_path, sqlmesh_macros_path, dirs_exist_ok=True)
        
        print(f"Conversion completed! SQLMesh project created at {self.output_path}")
        print("\nNext steps:")
        print("1. Review the generated config.yaml and adjust connection settings")
        print("2. Verify model configurations and dependencies")
        print("3. Test the SQLMesh project with: sqlmesh plan")


def main():
    parser = argparse.ArgumentParser(description="Convert dbt project to SQLMesh")
    parser.add_argument("dbt_project_path", help="Path to dbt project directory")
    parser.add_argument("output_path", help="Path for SQLMesh project output")
    
    args = parser.parse_args()
    
    converter = DBTToSQLMeshConverter(args.dbt_project_path, args.output_path)
    converter.convert_project()


if __name__ == "__main__":
    main()