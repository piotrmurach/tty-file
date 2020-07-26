# frozen_string_literal: true

RSpec.describe TTY::File, "#download_file", type: :sandbox do
  include_context "identical files"

  shared_context "downloading a file" do
    it "downloads a file from remote uri" do
      body = "##Header1\nCopy text.\n"
      stub_request(:get, "https://example.com/README.md").to_return(body: body)
      path = path_factory.call("doc/README.md")

      TTY::File.download_file("https://example.com/README.md", path, verbose: false)

      expect(File.read(path)).to eq(body)
    end

    it "yields content from remote uri" do
      body = "##Header1\nCopy text.\n"
      stub_request(:get, "https://example.com/README.md").to_return(body: body)
      path = path_factory.call("doc/README.md")

      TTY::File.download_file("https://example.com/README.md", path, verbose: false) do |content|
        expect(a_request(:get, "https://example.com/README.md")).to have_been_made
        expect(content).to eq(body)
      end
    end

    it "logs file operation" do
      body = "##Header1\nCopy text.\n"
      stub_request(:get, "https://example.com/README.md").to_return(body: body)
      path = path_factory.call("doc/README.md")

      expect {
        TTY::File.download_file("https://example.com/README.md", path)
      }.to output(/create(.*)doc\/README.md/).to_stdout_from_any_process
    end

    it "specifies limit on redirects" do
      stub_request(:get, "https://example.com/wrong").to_return(status: 302, headers: { location: "https://example.com/wrong_again"})
      stub_request(:get, "https://example.com/wrong_again").to_return(status: 302, headers: { location: "https://example.com/README.md"})

      path = path_factory.call("doc/README.md")

      expect {
        TTY::File.download_file("https://example.com/wrong", path, verbose: false, limit: 1)
      }.to raise_error(TTY::File::DownloadError)
    end

    it "copies the file from relative location if not URI" do
      src_path  = path_factory.call("Gemfile")
      dest_path = path_factory.call("app/Gemfile")

      TTY::File.get_file(src_path, dest_path, verbose: false)

      exists_and_identical?("Gemfile", "app/Gemfile")
    end
  end

  context "when passed a String instance for the file argument" do
    let(:path_factory) { ->(file) { file } }

    include_context "downloading a file"
  end

  context "when passed a Pathname instance for the file argument" do
    let(:path_factory) { ->(file) { Pathname(file) } }

    include_context "downloading a file"
  end
end
