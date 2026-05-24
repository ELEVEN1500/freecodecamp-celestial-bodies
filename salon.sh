#!/bin/bash

# Variável para conectar ao banco de dados PostgreSQL
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MEU SALÃO DE BELEZA ~~~~~\n"

MAIN_MENU() {
  # Se receber um argumento (mensagem de erro), exibe para o usuário
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Bem-vindo ao salão! Como posso te ajudar hoje?"
  
  # 1. Buscar e exibir a lista numerada de serviços
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Ler a escolha do usuário
  read SERVICE_ID_SELECTED

  # Verificar se o serviço existe
  HAVE_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # 2. Se o serviço não existir, mostra a lista novamente
  if [[ -z $HAVE_SERVICE ]]
  then
    MAIN_MENU "Desculpe, esse serviço não existe. Escolha uma opção válida."
  else
    # Se o serviço existir, prossegue com o agendamento
    SERVICE_NAME=$(echo $HAVE_SERVICE | sed 's/ //g')
    
    # 3. Solicitar o número de telefone
    echo -e "\nQual é o seu número de telefone?"
    read CUSTOMER_PHONE

    # Verificar se o cliente já existe no banco de dados
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # 4. Se o número não existir, solicitar o nome e cadastrar
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nNão encontramos seu cadastro. Qual é o seu nome?"
      read CUSTOMER_NAME
      
      # Inserir novo cliente
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # Formatar o nome do cliente (remover espaços em branco extras do psql)
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //g')

    # Pegar o customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Solicitar o horário do agendamento
    echo -e "\nQual horário você deseja agendar o seu/sua $SERVICE_NAME, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME

    # 5. Criar a linha na tabela de appointments (agendamentos)
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # 6. Exibir a mensagem final exata exigida pelo teste
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

# Chamar a função principal para iniciar o script
MAIN_MENU 
