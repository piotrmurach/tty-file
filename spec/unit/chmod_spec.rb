# frozen_string_literal: true

RSpec.describe TTY::File, '#chmod' do
  context 'when octal permisssions' do
    it "adds permissions to file - user executable",
      unless: RSpec::Support::OS.windows? do

      file = tmp_path('script.sh')
      mode = File.lstat(file).mode
      expect(File.executable?(file)).to eq(false)

      TTY::File.chmod(file, mode | TTY::File::U_X, verbose: false)

      expect(File.lstat(file).mode).to eq(mode | TTY::File::U_X)
    end

    it "logs status when :verbose flag is true",
      unless: RSpec::Support::OS.windows? do

      file = tmp_path('script.sh')
      mode = File.lstat(file).mode
      expect(File.executable?(file)).to eq(false)

      expect {
        TTY::File.chmod(file, mode | TTY::File::U_X)
      }.to output(/chmod/).to_stdout_from_any_process

      expect(File.lstat(file).mode).to eq(mode | TTY::File::U_X)
    end

    it "doesn't change permission when :noop flag is true" do
      file = tmp_path('script.sh')
      mode = File.lstat(file).mode
      expect(File.executable?(file)).to eq(false)

      TTY::File.chmod(file, mode | TTY::File::U_X, verbose: false, noop: true)

      expect(File.lstat(file).mode).to eq(mode)
    end
  end

  context 'when human readable permissions' do
    it "adds permisions to file - user executable",
      unless: RSpec::Support::OS.windows? do

      file = tmp_path('script.sh')
      mode = File.lstat(file).mode
      expect(File.executable?(file)).to eq(false)

      TTY::File.chmod(file, 'u+x', verbose: false)

      expect(File.lstat(file).mode).to eq(mode | TTY::File::U_X)
    end

    it "removes permission for user executable" do
      file = tmp_path('script.sh')
      mode = File.lstat(file).mode
      expect(File.writable?(file)).to eq(true)

      TTY::File.chmod(file, 'u-w', verbose: false)

      expect(File.lstat(file).mode).to eq(mode ^ TTY::File::U_W)
      expect(File.writable?(file)).to eq(false)
    end

    it "adds multiple permissions separated by comma",
      unless: RSpec::Support::OS.windows? do

      file = tmp_path('script.sh')
      mode = File.lstat(file).mode
      expect(File.executable?(file)).to eq(false)

      TTY::File.chmod(file, 'u+x,g+x', verbose: false)

      expect(File.lstat(file).mode).to eq(mode | TTY::File::U_X | TTY::File::G_X)
    end
  end
end
