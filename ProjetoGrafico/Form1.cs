using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ProjetoGrafico
{
    public partial class Form1 : Form
    {
        static int tamanho = 10;
        double[] x = new double[tamanho];
        double[] y = new double[tamanho];

        public Form1()
        {
            InitializeComponent();
        }

        private void btnOk_Click(object sender, EventArgs e)
        {
            zed.GraphPane.CurveList.Clear();

            for (int i = 0; i < tamanho; i++)
            {
                x[i] = i;
                y[i] = double.Parse(Microsoft.JScript.Eval.JScriptEvaluate(txtEntrada.Text.Replace("x", i.ToString()),
               Microsoft.JScript.Vsa.VsaEngine.CreateEngine()).ToString());


            }


            zed.GraphPane.AddCurve("minha curva", x, y, Color.Black);
            zed.RestoreScale(zed.GraphPane);
            zed.Refresh();
        }

        private void abrirToolStripMenuItem_Click(object sender, EventArgs e)
        {
            //OpenFileDialog ofd = new OpenFileDialog();
            //ofd.Title = "Arquivo de texto";
            //ofd.Filter = "TXT files|*.txt";
            //ofd.InitialDirectory = Application.StartupPath;
            //if (ofd.ShowDialog() == DialogResult.OK)
            //{
            //    string textoArquivo = System.IO.File.ReadAllText(ofd.FileName);

            //    string[] separadorPorEnter = new string[] { "\r\n" };
            //    string[] textoEnter = textoArquivo.Split(separadorPorEnter, StringSplitOptions.None);

            //    for (int i = 0; i < tamanho; i++)
            //    {
            //        string[] separadorPorEspaco = textoEnter[i].Split(' ');
            //        x[i] = double.Parse(separadorPorEspaco[0]);
            //        y[i] = double.Parse(separadorPorEspaco[1]);
            //    }
            //}
        }
    }
}
