using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Timers;
using System.Net;
using System.Diagnostics;
using System.IO;

namespace ConsoleApplication1
{
    class Program
    {
        public static void Main()
        {
            System.Timers.Timer aTimer = new System.Timers.Timer();
            aTimer.Elapsed += new ElapsedEventHandler(OnTimedEvent);
            // Set the Interval to 5 seconds.
            aTimer.Interval = 4000;
            aTimer.Enabled = true;

            Console.WriteLine("Press \'q\' to quit the sample.");
            while (Console.Read() != 'q') ;
        }

        // Specify what you want to happen when the Elapsed event is raised.
        private static void OnTimedEvent(object source, ElapsedEventArgs e)
        {
            WebClient client = new WebClient();
            string ret="";
            // set the user agent to IE6
            client.Headers.Add("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.0.3705;)");
            try
            {
                // actually execute the GET request
                ret = client.DownloadString("http://localhost/video/list/test.txt");

                // ret now contains the contents of the webpage
                //Console.WriteLine("Content: " + ret);
            }
            catch (WebException we)
            {
                // WebException.Status holds useful information
                Console.WriteLine(we.Message + "\n" + we.Status.ToString());
            }
            catch (NotSupportedException ne)
            {
                // other errors
                Console.WriteLine(ne.Message);
            } //Console.WriteLine("Uncatched error!");

            client.DownloadString("http://169.14.55.28/video/select.aspx?file=");
            if (ret.Contains("demo"))
            {

                ProcessStartInfo startInfo = new ProcessStartInfo();

                startInfo.FileName = @"C:\Program Files (x86)\Stereoscopic Player\StereoPlayer.exe";
                startInfo.Arguments = " -file:" + ret;
                Console.WriteLine("opening...");
                Process.Start(startInfo);
            }
   //         System.Diagnostics.Process.Start(commandline);
        }
    }
}
