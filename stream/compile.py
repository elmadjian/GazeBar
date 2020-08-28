import os

path = "C:\Windows\Microsoft.NET\Framework\\v4.0.30319\csc.exe" +\
       " /platform:x86 /t:exe /out:streamer.exe" +\
       " /r:Tobii.Interaction.Model.dll,Tobii.Interaction.Net.dll .\streamer.cs"

out = os.popen(path)
print(out.read())