#include "Protheus.ch" 
#include "Rwmake.ch" 
#include "Topconn.ch" 

User Function HSMARKFIN() 

Local _astru:={} 
Local _afields:={} 
Local _carq              
Local oMark 
Local cQuery   := "" 

Private arotina := {}    
Private cCadastro 
Private cMark:=GetMark() 


aAdd( aRotina ,{"Marcar"    ,"u_Marcar()" ,0,3}) 
aAdd( aRotina ,{"Desmarcar" ,"u_DESMAR()" ,0,2}) 
aAdd( aRotina ,{"Inverter" ,"u_MARKALL()" ,0,4}) 
aAdd( aRotina ,{"Legenda"   ,"u_xLegend()" ,0,5}) 
              
/* 

aRotina   :={{ "Marcar Todos"   ,"U_MARCAR" , 0,4},;               
               { "Desmarcar Todos" ,"U_DESMAR" , 0,4},; 
               { "Inverter Todos" ,"U_MARKALL" , 0,4}} 

*/ 
                
cCadastro := "Arquivo Temporario" 

// Estrutura da tabela temporaria 

Aadd(_astru,{"E1_OK"     ,"C",02}) 
Aadd(_astru,{"E1_NUM"    ,"C",06}) 
Aadd(_astru,{"E1_PREFIXO","C",2,0}) 
Aadd(_astru,{"E1_PARCELA","C",2,0}) 
Aadd(_astru,{"E1_VALOR" ,"N",17,2}) 

// cria a tabela temporária 

_carq:="T_"+Criatrab(,.F.) 
MsCreate(_carq,_astru,"DBFCDX") 
Sleep(1000) 

// atribui a tabela temporária ao alias TRB 

dbUseArea(.T.,"DBFCDX",_cARq,"TRB",.T.,.F.) 

// QUERY 
cQuery := "SELECT E1_NUM ,E1_PREFIXO ,E1_PARCELA " 
cQuery += "FROM " + RetSqlName("SE1")+ " AS E1 " 
cQuery += "WHERE E1.D_E_L_E_T_ <> '*' " 
cQuery += "AND E1_EMISSAO BETWEEN '20130801' AND '20130827' AND E1_BAIXA = ''  " 
cQuery += "ORDER BY E1_NUM " 

//TCQuery cQuery new Alias "TRB1" 

IF Select("TRB1") > 0 
     DbSelectArea("TRB1") 
     DbCloseArea("TRB1") 
ENDIF 
                          
TCQUERY cQuery ALIAS "TRB1" NEW     

TCSETFIELD("TRB1","E1_NUM"       ,"C", 06) 
TCSETFIELD("TRB1","E1_PREFIXO"   ,"C", 02) 
TCSETFIELD("TRB1","E1_PARCELA"   ,"C", 02) 
TCSETFIELD("TRB1","E1_VALOR"     ,"N",17,2) 

Dbselectarea("TRB1") 
TRB1->(Dbgotop()) 

While TRB1->(!Eof())        

     DbSelectArea("TRB")        
     RecLock("TRB",.T.)                  

     TRB->E1_OK       := " " 
     TRB->E1_NUM      :=TRB1->E1_NUM               
     TRB->E1_PREFIXO  :=TRB1->E1_PREFIXO                  
     TRB->E1_PARCELA  :=TRB1->E1_PARCELA                  
     TRB->E1_VALOR    :=TRB1->E1_VALOR               

     Msunlock()        

     DbSelectArea("TRB")        
     TRB1->(Dbskip()) 

EndDo 

Aadd(_afields,{"E1_OK","",""}) 
Aadd(_afields,{"E1_NUM","","Titulo"}) 
Aadd(_afields,{"E1_PREFIXO","","Prefixo"}) 
Aadd(_afields,{"E1_PARCELA","","Parcela"}) 
Aadd(_afields,{"E1_VALOR","","Valor"}) 


dbSelectArea("TRB") 
DbGotop() 

MarkBrow( "TRB", "E1_OK",,_afields,, cMark,"u_MarkAll()",,,,"u_Mark()",{|| u_MarkAll()},,,,,,,.F.) 

DbCloseArea()      

// apaga a tabela temporário 
MsErase(_carq+GetDBExtension(),,"DBFCDX") 

Return 

User Function Marcar()                             

Local oMark := GetMarkBrow() 

DbSelectArea("TRB") 
DbGotop() 
     While !Eof()        
          If RecLock( "TRB", .F. )               
               TRB->E1_OK := cMark               
               MsUnLock()        
          EndIf        
     dbSkip() 
     Enddo 
     MarkBRefresh()       
     // força o posicionamento do browse no primeiro registro 
     oMark:oBrowse:Gotop() 
Return 

User Function DesMar() 

Local oMark := GetMarkBrow() 

DbSelectArea("TRB") 
DbGotop() 
      
     While !Eof()        
           
          If RecLock( "TRB", .F. )               
               TRB->E1_OK := SPACE(2)               
          MsUnLock()        
           
          EndIf        
           
          dbSkip() 
      
     Enddo 

MarkBRefresh() 

// força o posicionamento do browse no primeiro registro 

oMark:oBrowse:Gotop() 

Return 
// Grava marca no campo 
User Function Mark() 
      
     If IsMark( "E1_OK", cMark )        
          RecLock( "TRB", .F. )               
               Replace E1_OK With Space(2)        
          MsUnLock() 
     Else        
          RecLock("TRB", .F. )               
               Replace E1_OK With cMark        
          MsUnLock() 
     EndIf 
Return 

// Grava marca em todos os registros validos 
User Function MarkAll()    

Local oMark := GetMarkBrow() 

dbSelectArea("TRB") 
dbGotop() 
     While !Eof()        
           
          u_Mark()        
           
          dbSkip() 
     End 

MarkBRefresh()// força o posicionamento do browse no primeiro registro 

oMark:oBrowse:Gotop() 

Return 


User Function xLegend() 

Local aCor := {} 

aAdd(aCor,{"BR_VERDE"   ,"Não Transferida"}) 
aAdd(aCor,{"BR_VERMELHO","NF Transferida"    }) 

BrwLegenda(cCadastro,"Status dos Registros",aCor) 

Return 