control "world-1.0" do                                # A unique ID for this control
    impact 1.0                                          # Just how critical is
    title "Hello World"                                 # Readable by a human
    desc "Text should include the words 'hello world'." # Optional description
    # describe file('hello.txt') do                       # The actual test
    #  its('content') { should match 'Hello World' }      # You could just do the "describe file" block if you want. The  
    # end  
    
    describe docker.version do
      its('Server.Version') { should cmp >= '1.12'}
      its('Client.Version') { should cmp >= '1.12'}
    end
    describe docker.containers do
      its('images') { should include 'laoservice' }
    end
 
    describe docker_container('loanservice') do
      it { should exist }
      it { should be_running }
      its('repo') { should eq 'laoservice' }
      its('ports') { should eq "0.0.0.0:8443->8443/tcp" }
      its('command') { should eq 'dotnet eo-svc-lao.dll' }
    end


    
  end
