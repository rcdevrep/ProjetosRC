#INCLUDE "rwmake.ch"       

User Function AGX613()

Private cCadastro := "Cadastro de Leads" 

aCores :=   {{'EMPTY(SZ4->Z4_STATUS)', 'ENABLE'},;        // A SER ATENDIDO 
             {'Z4_STATUS =="Q"' , 'BR_VERMELHO' },;        // QUENTE
             {'Z4_STATUS =="S"' , 'BR_PINK'      },;        // SEM PREVISAO
             {'Z4_STATUS =="M"' , 'BR_CINZA'     },;        // MORNO
             {'Z4_STATUS =="F"' , 'BR_BRANCO'    },;        // FRIO
             {'Z4_STATUS =="E"' , 'BR_MARRON'    },;        // PRODUTO ERRADO
             {'Z4_STATUS =="H"' , 'DISABLE   '   },;        // FECHADO
             {'Z4_STATUS =="D"' , 'BR_PRETO'     }}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta um aRotina proprio                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aRotina := { {"Pesquisar","AxPesqui",0,1 } ,;
                     {"Visualizar","AxVisual",0,2} ,;
                     {"Incluir","AxInclui",0,3   } ,;
                     {"Alterar","AxAltera",0,4   } ,;
                     {"Legenda","U_Leadleg()",0,5},;
                     {"Excluir","AxDeleta",0,6   }}

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "SZ4"

dbSelectArea("SZ4")
dbSetOrder(1)   
mBrowse( 6,1,22,75,cString,,,,,6,aCores)
Return 
        

User Function Leadleg    // função para leenda colorida

       
        aLegenda := {{"BR_VERMELHO","QUENTE"},;
                     {"BR_VERDE", "A SER ATENDIDO"},;
                     {"BR_PINK", "SEM PREVISÃO"},;
                     {"BR_CINZA", "MORNO"},;
                     {"BR_MARRON", "ERRADO"},;
                     {"BR_BRANCO", "FRIO"},;
                     {"BR_AMARELO","FECHADO" },;
                     {"BR_PRETO","DESISTENTE"}} 

	BrwLegenda("Situação do Atendimento no Sistema !!!","Legenda",aLegenda)
return