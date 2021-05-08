using System;
using Tobii.Interaction;


    public class Streamer
    {
        public static void Main(string[] args)
        {
            var host = new Host();

            System.Net.Sockets.UdpClient client = new System.Net.Sockets.UdpClient();
            client.Connect("127.0.0.1", 9998);

            var gazePointDataStream = host.Streams.CreateGazePointDataStream();

            gazePointDataStream.GazePoint((x,y,_) => {
                string message = "g~"+x.ToString()+'~'+y.ToString();
                var datagram = System.Text.Encoding.ASCII.GetBytes(message);
                client.Send(datagram, datagram.Length);
            });

            Console.ReadKey();
            host.DisableConnection();
        }

    }

