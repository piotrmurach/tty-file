# frozen_string_literal: true

RSpec.describe TTY::File, "#copy_directory", type: :sandbox do
  shared_context "copies directory" do
    it "copies directory of files recursively" do
      app  = path_factory.call("cli_app")
      apps = path_factory.call("apps")

      variables = OpenStruct.new
      variables[:name] = "tty"
      variables[:foo] = "Foo"
      variables[:bar] = "Bar"

      TTY::File.copy_directory(app, apps, context: variables, verbose: false)

      expect(Find.find(apps.to_s).to_a).to eq([
        "apps",
        "apps/README",
        "apps/command.rb",
        "apps/commands",
        "apps/commands/subcommand.rb",
        "apps/excluded",
        "apps/excluded/command.rb",
        "apps/excluded/tty_cli.rb",
        "apps/tty_cli.rb"
      ])

      expect(File.read("apps/command.rb")).to eq("class FooCommand\nend\n")
      expect(File.read("apps/excluded/command.rb")).to eq("class BarCommand\nend\n")
    end

    it "copies top level directory of files and evalutes templates" do
      app  = path_factory.call("cli_app")
      apps = path_factory.call("apps")

      variables = OpenStruct.new
      variables[:name] = "tty"
      variables[:foo] = "Foo"
      variables[:bar] = "Bar"

      TTY::File.copy_directory(app, apps, recursive: false,
                                          context: variables,
                                          verbose: false)

      expect(Find.find(apps.to_s).to_a).to eq([
        "apps",
        "apps/README",
        "apps/command.rb",
        "apps/tty_cli.rb"
      ])
    end

    it "handles glob characters in the path" do
      src  = path_factory.call("foo[1]")
      dest = path_factory.call("foo1")
      TTY::File.copy_directory(src, dest, verbose: false)

      expect(Find.find(dest.to_s).to_a).to eq([
        "foo1",
        "foo1/README.md"
      ])
    end

    it "ignores excluded directories" do
      src  = path_factory.call("cli_app")
      dest = path_factory.call("ignored")

      variables = OpenStruct.new
      variables[:name] = "tty"
      variables[:foo] = "Foo"
      variables[:bar] = "Bar"

      TTY::File.copy_directory(src, dest, context: variables,
                                          exclude: %r{excluded/},
                                          verbose: false)

      expect(Find.find(dest.to_s).to_a).to eq([
        "ignored",
        "ignored/README",
        "ignored/command.rb",
        "ignored/commands",
        "ignored/commands/subcommand.rb",
        "ignored/tty_cli.rb"
      ])
    end

    it "raises error when source directory doesn't exist" do
      expect {
        TTY::File.copy_directory("unknown")
      }.to raise_error(ArgumentError, %r{File path "unknown" does not exist.})
    end

    it "logs status" do
      app  = path_factory.call("cli_app")
      apps = path_factory.call("apps")

      variables = OpenStruct.new
      variables[:name] = "tty"
      variables[:class_name] = "TTY"

      expect {
        TTY::File.copy_directory(app, apps, context: variables, verbose: true)
      }.to output(
        %r{create(.*)apps/tty_cli.rb\n(.*)create(.*)apps/README\n(.*)create(.*)apps/command.rb\n}m
      ).to_stdout_from_any_process
    end
  end

  context "when passed String instances for the file arguments" do
    let(:path_factory) { ->(file) { file } }

    it_behaves_like "copies directory"
  end

  context "when passed Pathname instances for the file arguments" do
    let(:path_factory) { ->(file) { Pathname(file) } }

    it_behaves_like "copies directory"
  end
end
