# frozen_string_literal: true

RSpec.describe TTY::File, '#copy_directory' do
  it "copies directory of files recursively" do
    app = tmp_path('cli_app')
    apps = tmp_path('apps')

    variables = OpenStruct.new
    variables[:name] = 'tty'
    variables[:foo] = 'Foo'
    variables[:bar] = 'Bar'

    TTY::File.copy_directory(app, apps, context: variables, verbose: false)

    expect(Find.find(apps).to_a).to eq([
      tmp_path('apps'),
      tmp_path('apps/README'),
      tmp_path('apps/command.rb'),
      tmp_path('apps/commands'),
      tmp_path('apps/commands/subcommand.rb'),
      tmp_path('apps/excluded'),
      tmp_path('apps/excluded/command.rb'),
      tmp_path('apps/excluded/tty_cli.rb'),
      tmp_path('apps/tty_cli.rb')
    ])

    expect(File.read(tmp_path('apps/command.rb'))).to eq("class FooCommand\nend\n")
    expect(File.read(tmp_path('apps/excluded/command.rb'))).to eq("class BarCommand\nend\n")
  end

  it "copies top level directory of files and evalutes templates" do
    app  = tmp_path('cli_app')
    apps = tmp_path('apps')

    variables = OpenStruct.new
    variables[:name] = 'tty'
    variables[:foo] = 'Foo'
    variables[:bar] = 'Bar'

    TTY::File.copy_directory(app, apps, recursive: false,
                                        context: variables,
                                        verbose: false)

    expect(Find.find(apps).to_a).to eq([
      tmp_path('apps'),
      tmp_path('apps/README'),
      tmp_path('apps/command.rb'),
      tmp_path('apps/tty_cli.rb')
    ])
  end

  it "handles glob characters in the path" do
    src = tmp_path("foo[1]")
    dest = tmp_path("foo1")
    TTY::File.copy_directory(src, dest, verbose: false)

    expect(Find.find(dest).to_a).to eq([
      tmp_path('foo1'),
      tmp_path('foo1/README.md')
    ])
  end

  it "ignores excluded directories" do
    src = tmp_path('cli_app')
    dest = tmp_path('ignored')

    variables = OpenStruct.new
    variables[:name] = 'tty'
    variables[:foo] = 'Foo'
    variables[:bar] = 'Bar'

    TTY::File.copy_directory(src, dest, context: variables,
                                        exclude: %r{excluded/},
                                        verbose: false)

    expect(Find.find(dest).to_a).to eq([
      tmp_path('ignored'),
      tmp_path('ignored/README'),
      tmp_path('ignored/command.rb'),
      tmp_path('ignored/commands'),
      tmp_path('ignored/commands/subcommand.rb'),
      tmp_path('ignored/tty_cli.rb')
    ])
  end

  it "raises error when source directory doesn't exist" do
    expect {
      TTY::File.copy_directory('unknown')
    }.to raise_error(ArgumentError, %r{File path "unknown" does not exist.})
  end

  it "logs status" do
    app  = tmp_path('cli_app')
    apps = tmp_path('apps')

    variables = OpenStruct.new
    variables[:name] = 'tty'
    variables[:class_name] = 'TTY'

    expect {
      TTY::File.copy_directory(app, apps, context: variables, verbose: true)
    }.to output(
      %r{create(.*)apps/tty_cli.rb\n(.*)create(.*)apps/README\n(.*)create(.*)apps/command.rb\n}m
    ).to_stdout_from_any_process
  end
end
