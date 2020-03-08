using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ManipulandoJson
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            Pessoa p1 = new Pessoa() { nome = "Júlio", email = "julio@juliocsoft.com", telefone = "31 987584857" };
            Pessoa p2 = new Pessoa() { nome = "Luci", email = "luci@gmail.com", telefone = "31 988827192" };

            Carro c1 = new Carro() { modelo = "corsa sedan" };
            Carro c2 = new Carro() { modelo = "fiesta", ano = 2010 };
            Carro c3 = new Carro() { modelo = "fiesta", ano = 2010, valor = 5000.80 };

            p1.listaCarro.Add(c1);
            p1.listaCarro.Add(c2);

            p2.listaCarro.Add(c3);

            //Serializa e Descerializa no JSON
            string json = JsonConvert.SerializeObject(p1);

            
            Pessoa pessoaJson = JsonConvert.DeserializeObject<Pessoa>(json);
        }
    }
}
