require_relative "../../../../base"

describe "VagrantPlugins::GuestDarwin::Cap::ShellExpandGuestPath" do
  let(:caps) do
    VagrantPlugins::GuestDarwin::Plugin
      .components
      .guest_capabilities[:darwin]
  end

  let(:machine) { double("machine") }
  let(:comm) { VagrantTests::DummyCommunicator::Communicator.new(machine) }

  before do
    allow(machine).to receive(:communicate).and_return(comm)
  end

  describe "#shell_expand_guest_path" do
    let(:cap) { caps.get(:shell_expand_guest_path) }

    it "expands the path" do
      path = "/home/vagrant/folder"
      allow(machine.communicate).to receive(:execute).
        with(any_args).and_yield(:stdout, "/home/vagrant/folder")

      cap.shell_expand_guest_path(machine, path)
    end

    it "raises an exception if no path was detected" do
      path = "/home/vagrant/folder"
      expect { cap.shell_expand_guest_path(machine, path) }.
        to raise_error(Vagrant::Errors::ShellExpandFailed)
    end

    it "returns a path with a space in it" do
      path = "/home/vagrant folder/folder"
      allow(machine.communicate).to receive(:execute).
        with(any_args).and_yield(:stdout, "/home/vagrant folder/folder")

      expect(machine.communicate).to receive(:execute).with("printf \"#{path}\"")
      cap.shell_expand_guest_path(machine, path)
    end
  end
end