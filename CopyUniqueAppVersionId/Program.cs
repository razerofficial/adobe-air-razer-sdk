using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Xml;

namespace CopyUniqueAppVersionId
{
    class Program
    {
        static string GetUniqueAppVersionId(string path)
        {
            XmlDocument xDoc = new XmlDocument();
            xDoc.Load(path);
            foreach (XmlNode node in xDoc.SelectNodes("/manifest/application/activity/meta-data"))
            {
                if (node is XmlElement)
                {
                    XmlElement element = node as XmlElement;
                    if (element.GetAttribute("android:name") == "uniqueappversionid")
                    {
                        string result = element.GetAttribute("android:value");
                        return result;
                    }
                }
            }
            return string.Empty;
        }
        static void SetUniqueAppVersionId(string path, string uuid)
        {
            XmlDocument xDoc = new XmlDocument();
            xDoc.Load(path);
            foreach (XmlNode node in xDoc.SelectNodes("/manifest/application/activity/meta-data"))
            {
                if (node is XmlElement)
                {
                    XmlElement element = node as XmlElement;
                    if (element.GetAttribute("android:name") == "uniqueappversionid")
                    {
                        element.SetAttribute("android:value", uuid);
                        xDoc.Save(path);
                    }
                }
            }
        }
        static void Main(string[] args)
        {
            Console.WriteLine("Working Directory={0}", Directory.GetCurrentDirectory());
            if (args.Length < 2)
            {
                return;
            }
            Console.WriteLine("Source File={0}", args[0]);
            String uniqueAppVersionId = GetUniqueAppVersionId(args[0]);
            Console.WriteLine("Unique App Version Id={0}", uniqueAppVersionId);
            Console.WriteLine("Destination File={0}", args[1]);
            SetUniqueAppVersionId(args[1], uniqueAppVersionId);


        }
    }
}
