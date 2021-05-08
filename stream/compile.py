import os

if os.name == 'nt':
       path = "C:\Windows\Microsoft.NET\Framework\\v4.0.30319\csc.exe" +\
              " /platform:x86 /t:exe /out:streamer.exe" +\
              " /r:Tobii.Interaction.Model.dll,Tobii.Interaction.Net.dll .\streamer.cs"
else:
       path = "mkdir build && cd build && cmake .. && make && mv streamer ../"
out = os.popen(path)
print(out.read())       

