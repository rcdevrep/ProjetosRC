#Include "PROTHEUS.CH" 
#Include "RWMAKE.CH"                       

//---------------------------------------------//
//    Função:SMSAGR01                          //
//    Utilização: Cadastro de Endereçamento    //
//    Data: 28/09/2015                         //
//    Autor: Leandro Spiller                   //                               
//---------------------------------------------//
User Function SMSAGR01()     

	Local cAlias  := 'Z03'
	Local cTitulo := 'Cadastro de Endereçamento'
	Local cVldExc := ".T."//"U_SMS01EXC()"
	Local cVldAlt := ".T."//"U_SMS01ALT()"  
	Local aRotAdic :={}
	
	aadd(aRotAdic,{ "Gerar End.","U_SMS01GER", 0 , 6 })     
	Dbselectarea('Z03') 
	DbSetOrder(1)

	AxCadastro(cAlias,cTitulo    ,cVldExc     ,cVldAlt   , aRotAdic )
 //	AxCadastro("SA1" , "Clientes", "U_DelOk()", "U_COK()", aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , )  

Return
       
/*User Function SMS01EXC()  

	Reclock('Z03',.F.)
    	Dbdelete()
	MsUnlock()

Return .T.
  */
                                
User Function SMS01GER()

Static oDlg
Static oButton1
Static oButton2
Static oGet1
Static oGet2
Static oGet3
Static oGet4
Static oGet5
Static oGet6
Static oGet7
Static oSay1
Static oSay2
Static oSay3
Static oSay4
Static oSay5
Static oSay6
Static oSay7
Static oSay8
Private cGetRua := "   "
Private cGetPre1 := "   "
Private cGetPre2 := "   "
Private cGetNiv1 := "  "
Private cGetNiv2 := "  "
Private cGetApt1 := "   "
Private cGetApt2 := "   "



  DEFINE MSDIALOG oDlg TITLE "Cadastro de Endereçamento" FROM 000, 000  TO 200, 400 COLORS 0, 16777215 PIXEL

    @ 009, 001+10 SAY oSay2 PROMPT "Rua: " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 010, 040+10 MSGET oGet1 VAR cGetRua SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
   
    @ 024, 001+10 SAY oSay3 PROMPT "Predio:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 025, 040+10 MSGET oGet2 VAR cGetPre1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 025, 121+10 MSGET oGet3 VAR cGetPre2 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
   
    @ 039, 001+10 SAY oSay5 PROMPT "Nível:" SIZE 031, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 040, 040+10 MSGET oGet4 VAR cGetNiv1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 040, 121+10 MSGET oGet5 VAR cGetNiv2 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
   
    @ 054, 001+10 SAY oSay4 PROMPT "Apartamento:" SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 055, 040+10 MSGET oGet6 VAR cGetApt1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 055, 121+10 MSGET oGet7 VAR cGetApt2 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
   
    @ 025, 105+10 SAY oSay6 PROMPT "até" SIZE 011, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 040, 105+10 SAY oSay7 PROMPT "até" SIZE 009, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 055, 105+10 SAY oSay8 PROMPT "até" SIZE 010, 007 OF oDlg COLORS 0, 16777215 PIXEL
    
    @ 075, 145+10 BUTTON oButton1 PROMPT "Incluir" SIZE 037, 012 OF oDlg ACTION(IIF(Incluir(),oDlg:End(),)) PIXEL  
    //@ 075, 090+10 BUTTON oButton2 PROMPT "Incluir" SIZE 037, 012 OF oDlg ACTION(IIF(Incluir(),oDlg:End(),)) PIXEL  
    
  ACTIVATE MSDIALOG oDlg CENTERED

Return                                                                                 
      
   
//- - - - - - - - - - - -//
// Função de Inclusão    //
//- - - - - - - - - - - -//
Static function Incluir() 

 Local aPredio := {} 
 Local aNivel  := {}
 Local aApart  := {}   
 Local aChaves := {}
 Local cChave := ""
                         
If Alltrim(cGetRua)   == "" .or. Alltrim(cGetPre1)  == "" .or.;
	Alltrim(cGetPre2)  == "" .or. Alltrim(cGetNiv1)  == "" .or.;
	 Alltrim(cGetNiv2)  == "" .or. Alltrim(cGetApt1)  == "" .or.;
		Alltrim(cGetApt2)  == ""
 
		Alert('Preencha todos os campos!')
		
		Return(.F.)		
Endif		

 //grava predio                
 For i := val(Substr(cGetPre1,2,2)) to val(Substr(cGetPre2,2,2)) 
 	 aadd(apredio,i)          
 Next i       
 
 //grava nivel      
 For i := val(Substr(cGetNiv1,2,2)) to val(Substr(cGetNiv2,2,2)) 
 	 aadd(aNivel,i)          
 Next i 
 
 //grava aprovacao     
 For i := val(Substr(cGetApt1,2,2)) to val(Substr(cGetApt2,2,2)) 
 	 aadd(aApart,i)          
 Next i 
       
  
 //Gera códigos possíveis
 For i := 1 to len(apredio)    
 	For ia := 1 to len(aNivel)
 		For ib := 1 to len(aApart)   
 			
 			//Cria chaves de Busca
 			cChave := cGetRua
 			cChave += Substr(alltrim(cGetPre1),1,1) + Strzero(apredio[i],2)
 			cChave += Substr(alltrim(cGetNiv1),1,1) + Strzero(aNivel[ia],1)
 			cChave += Substr(alltrim(cGetApt1),1,1) + Strzero(aApart[ib],2)
 		    AADD(aChaves,cChave)
 			
 		Next ib
 	Next ia   
 Next i	
 
 For I := 1 to len(aChaves)
 	
 	Dbselectarea('Z03')
 	Dbsetorder(1)
    If Dbseek(xfilial('Z03')+ALLTRIM(aChaves[I]))
    
    	alert('Já existe um cadastro com a chave: '+UPPER(aChaves[I]))    
    
    Else
    
    	Reclock('Z03',.T.)  
    	      
    	    Z03_FILIAL  := xFilial('Z03')
  			Z03_RUA     := UPPER(Substr(Alltrim(aChaves[i]),1,3))
  			Z03_PREDIO  := UPPER(Substr(Alltrim(aChaves[i]),4,3))
  			Z03_NIVEL   := UPPER(Substr(Alltrim(aChaves[i]),7,2))
  			Z03_XAPTO   := UPPER(Substr(Alltrim(aChaves[i]),9,3))
    		
    	Z03->(Msunlock())
    
    Endif

 Next I
  
 Z03->(Dbgotop())
Return(.T.)