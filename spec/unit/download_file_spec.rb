# frozen_string_literal: true

RSpec.describe TTY::File, '#download_file' do
  it "downloads a file from remote uri" do
    body = "##Header1\nCopy text.\n"
    stub_request(:get, "https://example.com/README.md").to_return(body: body)
    path = tmp_path('doc/README.md')

    TTY::File.download_file('https://example.com/README.md', path, verbose: false)

    expect(File.read(path)).to eq(body)
  end

  it "yields content from remoe uri" do
    body = "##Header1\nCopy text.\n"
    stub_request(:get, "https://example.com/README.md").to_return(body: body)
    path = tmp_path('doc/README.md')

    TTY::File.download_file('https://example.com/README.md', path, verbose: false) do |content|
      expect(a_request(:get, 'https://example.com/README.md')).to have_been_made
      expect(content).to eq(body)
    end
  end

  it "logs file operation" do
    body = "##Header1\nCopy text.\n"
    stub_request(:get, "https://example.com/README.md").to_return(body: body)
    path = tmp_path('doc/README.md')

    expect {
      TTY::File.download_file('https://example.com/README.md', path)
    }.to output(/create(.*)doc\/README.md/).to_stdout_from_any_process
  end

  it "specifies limit on redirects" do
    stub_request(:get, "https://example.com/wrong").to_return(status: 302, headers: { location: 'https://example.com/wrong_again'})
    stub_request(:get, "https://example.com/wrong_again").to_return(status: 302, headers: { location: 'https://example.com/README.md'})

    path = tmp_path('doc/README.md')

    expect {
      TTY::File.download_file('https://example.com/wrong', path, verbose: false, limit: 1)
    }.to raise_error(TTY::File::DownloadError)
  end

  it "copies the file from relative location if not URI" do
    src_path  = tmp_path('Gemfile')
    dest_path = tmp_path('app/Gemfile')

    TTY::File.get_file(src_path, dest_path, verbose: false)

    exists_and_identical?('Gemfile', 'app/Gemfile')
  end
end
