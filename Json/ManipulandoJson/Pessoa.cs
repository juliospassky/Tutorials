using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ManipulandoJson
{
    public class Pessoa
    {
        public string nome { get; set; }
        public string email { get; set; }
        public string telefone { get; set; }
        public List<Carro> listaCarro = new List<Carro>();
    }
}
