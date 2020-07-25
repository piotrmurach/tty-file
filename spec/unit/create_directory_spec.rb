# frozen_string_literal: true

RSpec.describe TTY::File, "#create_directory", type: :sandbox do
  it "creates empty directory" do
    TTY::File.create_directory("app", verbose: false)

    expect(File.exist?("app")).to eq(true)
  end

  it "logs status" do
    expect {
      TTY::File.create_dir("doc", verbose: true)
    }.to output(%r{    \e\[32mcreate\e\[0m(.*)doc\n}).to_stdout_from_any_process
  end

  it "logs status wihtout color" do
    expect {
      TTY::File.create_dir("doc", verbose: true, color: false)
    }.to output(%r{    create(.*)doc\n}).to_stdout_from_any_process
  end

  it "creates tree of dirs and files" do
    tree = {
      "app" => [
        "empty_file",
        ["full_file", "File with contents"],
        "subdir" => [
          "empty_file_subdir",
          ["full_file_subdir", "File with contents"]
        ],
        "empty" => []
      ]
    }

    TTY::File.create_directory(tree, verbose: false)

    expect(Find.find("app").to_a).to eq([
      "app",
      "app/empty",
      "app/empty_file",
      "app/full_file",
      "app/subdir",
      "app/subdir/empty_file_subdir",
      "app/subdir/full_file_subdir"
    ])

    expect(::File.read("app/subdir/full_file_subdir")).to eq("File with contents")
  end

  it "creates tree of dirs in parent directory" do
    app_dir = "parent"

    tree = {
      "app" => [
        ["file", "File multi\nline contents"],
        "subdir" => ["file1", "file2"]
      ]
    }

    TTY::File.create_dir(tree, app_dir, verbose: false)

    expect(Find.find(app_dir.to_s).to_a).to eq([
      "parent",
      "parent/app",
      "parent/app/file",
      "parent/app/subdir",
      "parent/app/subdir/file1",
      "parent/app/subdir/file2"
    ])
  end
end
