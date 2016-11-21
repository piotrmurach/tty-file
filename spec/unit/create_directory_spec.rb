# encoding: utf-8

RSpec.describe TTY::File, '#create_directory' do
  it "creates empty directory" do
    app_dir = tmp_path('app')

    TTY::File.create_directory(app_dir, verbose: false)

    expect(File.exist?(app_dir)).to eq(true)
  end

  it "logs status" do
    doc_dir = tmp_path('doc')

    expect {
      TTY::File.create_dir(doc_dir, verbose: true)
    }.to output(%r{    create(.*)doc\n}).to_stdout_from_any_process
  end

  it "creates tree of dirs and files" do
    app_dir = tmp_path('app')

    tree = {
      tmp_path('app') => [
        'empty_file',
        ['full_file', 'File with contents'],
        'subdir' => [
          'empty_file_subdir',
          ['full_file_subdir', 'File with contents']
        ],
        'empty' => []
      ]
    }

    TTY::File.create_directory(tree, verbose: false)

    expect(Find.find(app_dir).to_a).to eq([
      tmp_path('app'),
      tmp_path('app/empty'),
      tmp_path('app/empty_file'),
      tmp_path('app/full_file'),
      tmp_path('app/subdir'),
      tmp_path('app/subdir/empty_file_subdir'),
      tmp_path('app/subdir/full_file_subdir'),
    ])

    expect(::File.read(tmp_path('app/subdir/full_file_subdir'))).to eq('File with contents')
  end
end
