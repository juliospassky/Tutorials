# Styleguides

## Mensagens de commit styleguide

- Usar modo imperativo ("Adiciona feature" nÃ£o "Adicionando feature" ou "Adicionada feature")
- Primeira linha deve ter no mÃ¡ximo 72 caracteres
- Considere descrever com detalhes no corpo do commit
- Considere usar um emoji no inÃ­cio da mensagem de commit

Emoji | Code | Commit Type
------------ | ------------- | -------------
:tada: | `:tada:` | initial commit
:art: | `:art:` | quando melhorar a estrutura/formato do cÃ³digo
:racehorse: | `:racehorse:` | quando melhorar a performance
:memo: | `:memo:` | quando escrever alguma documentaÃ§Ã£o
:bug: | `:bug:` | quando corrigir um bug
:fire: | `:fire:` | quando remover cÃ³digos ou arquivos
:green_heart: | `:green_heart:` | quando corrigir uma build no CI
:white_check_mark: | `:white_check_mark:` | quando adicionar testes
:lock: | `:lock:` | quando melhorar a seguranÃ§a
:arrow_up: | `:arrow_up:` | quando der upgrade em dependÃªncias
:arrow_down: | `:arrow_down:` | quando der downgrade em dependÃªncias
:poop: | `:poop:` | deprecated
:construction: | `:construction:` | em construÃ§Ã£o
:rocket: | `:rocket:` | nova feature
:see_no_evil: | `:see_no_evil:` | gambiarra
:gift: | `:gift:` | nova versÃ£o

### Exemplo
```bash
git commit -m ":memo: Adiciona instruÃ§Ãµes de contribuiÃ§Ã£o
>
> Foi criado o arquivo CONTRIBUTING.md com as instruÃ§Ãµes de
> como fazer um bom commit"
``` 