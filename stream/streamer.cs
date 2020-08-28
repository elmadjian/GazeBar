using System;
using Tobii.Interaction;


    public class Streamer
    {
        public static void Main(string[] args)
        {
            // Everything starts with initializing Host, which manages connection to the 
            // Tobii Engine and provides all the Tobii Core SDK functionality.
            // NOTE: Make sure that Tobii.EyeX.exe is running
            var host = new Host();

            System.Net.Sockets.UdpClient client = new System.Net.Sockets.UdpClient();
            client.Connect("127.0.0.1", 9998);

            var gazePointDataStream = host.Streams.CreateGazePointDataStream();
            //var headPoseStream = host.Streams.CreateHeadPoseStream();
            //var fixationDataStream = host.Streams.CreateFixationDataStream();

            gazePointDataStream.GazePoint((x,y,_) => {
                string message = "g~"+x.ToString()+'~'+y.ToString();
                var datagram = System.Text.Encoding.ASCII.GetBytes(message);
                client.Send(datagram, datagram.Length);
            });

            // headPoseStream.HeadPose((_,headPose,headAngle) => {
            //     string message = "h~"+headPose.ToString()+'~'+headAngle.ToString();
            //     var datagram = System.Text.Encoding.ASCII.GetBytes(message);
            //     client.Send(datagram, datagram.Length);
            // });

            // fixationDataStream.Begin((x,y,_) => {
            //     string message = x.ToString()+'~'+y.ToString();
            //     Console.WriteLine("BEGIN: " + message);
            // });

            // fixationDataStream.End((x,y,_) => {
            //     string message = x.ToString()+'~'+y.ToString();
            //     Console.WriteLine("END: " + message);
            // });

            Console.ReadKey();
            host.DisableConnection();
        }

    }

