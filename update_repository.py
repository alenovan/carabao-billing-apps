import re
import os

def find_dart_files(directory):
    """Find all Dart repository files recursively."""
    dart_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('Repository.dart'):
                dart_files.append(os.path.join(root, file))
    return dart_files

def update_repository_file(file_path):
    """Update a single repository file to use ApiHelper."""
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # Check if file already has been modified
    if 'ApiHelper.build' in content:
        print(f"Skipping {file_path} - already updated")
        return False

    # Add ApiHelper import
    import_statement = "import 'package:http/http.dart';\n"
    helper_import = "import '../../helper/api_helper.dart';\n"
    
    # Find the last import statement
    import_matches = list(re.finditer(r'^import.*?;$', content, re.MULTILINE))
    if import_matches:
        last_import = import_matches[-1]
        last_import_end = last_import.end()
        content = (content[:last_import_end] + '\n' + 
                  import_statement + helper_import + content[last_import_end:])

    # Find repository class implementation
    class_match = re.search(r'class\s+(\w+)\s+implements\s+(\w+)\s*{', content)
    if not class_match:
        print(f"No repository class found in {file_path}")
        return False

    class_name = class_match.group(1)
    
    # Replace or add client field and constructor
    constructor_pattern = rf'class\s+{class_name}\s+implements.*?{{'
    client_declaration = """
  final Client _client;

  {class_name}() : _client = ApiHelper.build();

""".format(class_name=class_name)

    content = re.sub(constructor_pattern, f'class {class_name} implements {class_match.group(2)} {{\n{client_declaration}', content)

    # Update http.get/post/put/delete calls
    content = re.sub(
        r'await\s+http\.(get|post|put|delete)',
        r'await _client.\1',
        content
    )

    # Save changes
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(content)

    print(f"Updated {file_path}")
    return True

def main():
    """Main function to update all repository files."""
    # Get the lib directory path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    lib_dir = os.path.join(script_dir, 'lib')
    
    if not os.path.exists(lib_dir):
        print("lib directory not found!")
        return

    # Find all repository files
    repository_files = find_dart_files(lib_dir)
    
    if not repository_files:
        print("No repository files found!")
        return

    print(f"Found {len(repository_files)} repository files")

    # Update each repository file
    updated_count = 0
    for file_path in repository_files:
        try:
            if update_repository_file(file_path):
                updated_count += 1
        except Exception as e:
            print(f"Error updating {file_path}: {str(e)}")

    print(f"\nUpdate complete. {updated_count} files modified.")
    
    # Print manual steps needed
    print("\nManual steps needed:")
    print("1. Update any repository tests")
    print("2. Verify navigation behavior")

if __name__ == "__main__":
    main()
