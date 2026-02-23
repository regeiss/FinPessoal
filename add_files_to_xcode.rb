#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'FinPessoal.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get main target
main_target = project.targets.find { |t| t.name == 'FinPessoal' }
test_target = project.targets.find { |t| t.name == 'FinPessoalTests' }

# Helper to find group recursively
def find_group(parent, path_components)
  return parent if path_components.empty?

  name = path_components.first
  child = parent.children.find { |c| c.display_name == name }

  if child.nil?
    # Create if doesn't exist
    child = parent.new_group(name)
  end

  find_group(child, path_components[1..-1])
end

# Find the FinPessoal group
fin_pessoal_group = project.main_group.children.find { |g| g.display_name == 'FinPessoal' }
tests_group = project.main_group.children.find { |g| g.display_name == 'FinPessoalTests' }

# Source files to add (path => [group_path_array, target])
source_files = [
  ['FinPessoal/Code/Features/Transaction/Model/PDFImportModels.swift', ['Code', 'Features', 'Transaction', 'Model'], main_target],
  ['FinPessoal/Code/Features/Transaction/Services/PDFImport/PDFExtractor.swift', ['Code', 'Features', 'Transaction', 'Services', 'PDFImport'], main_target],
  ['FinPessoal/Code/Features/Transaction/Services/PDFImport/MLModelManager.swift', ['Code', 'Features', 'Transaction', 'Services', 'PDFImport'], main_target],
  ['FinPessoal/Code/Features/Transaction/Services/PDFImport/StatementMLProcessor.swift', ['Code', 'Features', 'Transaction', 'Services', 'PDFImport'], main_target],
  ['FinPessoal/Code/Features/Transaction/Services/PDFImport/PDFStatementImportService.swift', ['Code', 'Features', 'Transaction', 'Services', 'PDFImport'], main_target],
  ['FinPessoal/Code/Features/Transaction/Screen/PDFImportReviewScreen.swift', ['Code', 'Features', 'Transaction', 'Screen'], main_target],
  ['FinPessoal/Code/Features/Transaction/ViewModel/PDFImportViewModel.swift', ['Code', 'Features', 'Transaction', 'ViewModel'], main_target]
]

# Test files
test_files = [
  ['FinPessoalTests/Features/Transaction/PDFImportModelsTests.swift', ['Features', 'Transaction'], test_target],
  ['FinPessoalTests/Features/Transaction/PDFExtractorTests.swift', ['Features', 'Transaction'], test_target],
  ['FinPessoalTests/Features/Transaction/MLModelManagerTests.swift', ['Features', 'Transaction'], test_target],
  ['FinPessoalTests/Features/Transaction/StatementMLProcessorTests.swift', ['Features', 'Transaction'], test_target],
  ['FinPessoalTests/Features/Transaction/PDFStatementImportServiceTests.swift', ['Features', 'Transaction'], test_target],
  ['FinPessoalTests/Features/Transaction/PDFImportViewModelTests.swift', ['Features', 'Transaction'], test_target]
]

puts "Adding source files to FinPessoal target..."
source_files.each do |file_path, group_path, target|
  if File.exist?(file_path)
    begin
      group = find_group(fin_pessoal_group, group_path)
      file_ref = group.new_reference(file_path)
      target.add_file_references([file_ref])
      puts "  ✓ Added #{File.basename(file_path)}"
    rescue => e
      puts "  ✗ Error adding #{File.basename(file_path)}: #{e.message}"
    end
  else
    puts "  ✗ File not found: #{file_path}"
  end
end

puts "\nAdding test files to FinPessoalTests target..."
test_files.each do |file_path, group_path, target|
  if File.exist?(file_path)
    begin
      group = find_group(tests_group, group_path)
      file_ref = group.new_reference(file_path)
      target.add_file_references([file_ref])
      puts "  ✓ Added #{File.basename(file_path)}"
    rescue => e
      puts "  ✗ Error adding #{File.basename(file_path)}: #{e.message}"
    end
  else
    puts "  ✗ File not found: #{file_path}"
  end
end

puts "\nSaving project..."
project.save

puts "✅ Successfully added all files to Xcode project!"
