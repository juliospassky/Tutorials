Referência: http://letanure.github.io/blog/2013/08/16/lista-de-expressoes-regulares-uteis/

# Regex

## Uteis
Nome entre 1 e 255: ^[a-zA-Z''-'\s]{1,255}$
E-mail: ^(?("")("".+?""@)|(([0-9a-zA-Z]((\.(?!\.))|[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-zA-Z])@))(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,6}))$
URL: ^(ht|f)tp(s?)\:\/\/[0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*(:(0-9)*)*(\/?)([a-zA-Z0-9\- \.\?\,\'\/\\\+&amp;%\$#_]*)?$
Número de telefone: (+99(99)9999-9999) [\+]\d{2}[\(]\d{2}[\)]\d{4}[\-]\d{4}

## Senhas
Password forte entre 8-10 chars: (?!^[0-9]*$)(?!^[a-zA-Z]*$)^([a-zA-Z0-9]{8,10})$
Maiúsculas, minúsculas e números: ^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\s).*$
Maiúsculas, minúsculas, caracteres especias e números com no mínimo 8 caracteres: (?=^.{8,}$)((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$

## Códigos postais
Americano (nnnnn ou nnnnn-nnnn): (\d{5}([\-]\d{4})?)
Brasileiro/CEP (nnnnn-nn): [0-9]{5}[\-]?[0-9]{3}

##Cartões de crédito
Amex: [0-9]{4} *[0-9]{6} *[0-9]{5}
Genérico: [0-9]{13,16}
Diners Club: ^([30|36|38]{2})([0-9]{12})$

## Data e horário
Básico ( DD.MM.YYYY ) (0[1-9]|1[0-9]|2[0-9]|3[01]).(0[1-9]|1[012]).[0-9]{4}
Americano ( YYYY-MM-DD ) ISO_8601 [0-9]{4}-(0[1-9]|1[012])-(0[1-9]|1[0-9]|2[0-9]|3[01])
Validação completa de data (YYYY-MM-DD) (?:19|20)[0-9]{2}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])-(?:30))|(?:(?:0[13578]|1[02])-31))
Verificações
se o ano é numérico e começa com 19 ou 20
se o mes é numérico, entre 01 e 12
se o dia é numérico entre 01-29
se o dia for 30 o mes nao deve ser 02
se o dia for 31, o valor do mes deve ser um dos seguintes 01, 03, 05, 07, 08, 10 ou 12

- Formato MM/DD/YYYY (0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])[- /.](19|20)\d\d 
- Formato MM/DD/YYYY, validado (?:(?:0[1-9]|1[0-2])[\/\\-. ]?(?:0[1-9]|[12][0-9])|(?:(?:0[13-9]|1[0-2])[\/\\-. ]?30)|(?:(?:0[13578]|1[02])[\/\\-. ]?31))[\/\\-. ]?(?:19|20)[0-9]{2} 
- Data com ano bissexto (?:19|20)(?:(?:[13579][26]|[02468][048])-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])-(?:30))|(?:(?:0[13578]|1[02])-31))|(?:[0-9]{2}-(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:(?!02)(?:0[1-9]|1[0-2])-(?:29|30))|(?:(?:0[13578]|1[02])-31))) 
- Tempo ( HH:MM:SS ) (0[0-9]|1[0-9]|2[0-3])(:[0-5][0-9]){2} 
- Datetime ( exemplo: 1990-12-31T23:59:60Z / 1996-12-19T16:39:57-08:00) /([0-2][0-9]{3})\-([0-1][0-9])\-([0-3][0-9])T([0-5][0-9])\:([0-5][0-9])\:([0-5][0-9])(Z|([\-\+]([0-1][0-9])\:00))/

## Outros
Endereço IPv4 ((^|\.)((25[0-5])|(2[0-4]\d)|(1\d\d)|([1-9]?\d))){4}$
EndereçoIPv6 ((^|:)([0-9a-fA-F]{0,4})){1,8}$
Domínios do tipo "abc.de" ^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$
Números com ou sem decimais ( 9 ou 9.9 ou 9,9 ) [-+]?[0-9]*[.,]?[0-9]+
UUID ^[0-9A-Fa-f]{8}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{12}$
Latitude ou Longitude -?\d{1,3}\.\d+
Preço ( 1.00 ) \d+(\.\d{2})?
Preço ( 1,00 ) \d+(,\d{2})?
ISBN (?:(?=.{17}$)97[89][ -](?:[0-9]+[ -]){2}[0-9]+[ -][0-9]|97[89][0-9]{10}|(?=.{13}$)(?:[0-9]+[ -]){2}[0-9]+[ -][0-9Xx]|[0-9]{9}[0-9Xx])

Combinando:
Simple one without dashes, ISBN: 13: 97[89][0-9]{10}
Simple one w/o dashes, ISBN: 10: [0-9]{9}[0-9Xx]
Complex one with dashes, ISBN: 13: (?=.{17}$)97[89]-(?:[0-9]+-){2}[0-9]+-[0-9]
Complex one with dashes, ISBN: 10: (?=.{13}$)(?:[0-9]+-){2}[0-9]+-[0-9Xx]
Md5 Hash: [0-9a-fA-F]{32}