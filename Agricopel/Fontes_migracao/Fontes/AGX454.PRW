#include "rwmake.ch"
#include "colors.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX454    บAutor  ณMicrosiga           บ Data ณ  07/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGX454()
PRIVATE oDlg    := Nil, oCon := Nil, oCan := Nil, oPar := Nil

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ AJUSTE NO SX1                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPerg := "AGX454"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Arquivo SPED         ?","mv_ch1","C",30,0,0,"G","","mv_par01","","\sped\","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	Processa({|| GeraArq()}, "Importando Arquivo SPED FISCAL! Aguarde...")
	Processa({|| Altera()},  "Alterando Arquivo! Aguarde...")
	Processa({|| ImpArq()},  "Gerando Novo Arquivo...")

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX452IMP บAutor  ณMicrosiga           บ Data ณ  06/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa o arquivo do SPED FISCAL                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GeraArq()

LOCAL nLineLength := 200, nTabSize := 3, lWrap := .F. , nRec := 1
LOCAL nLines, nCurrentLine
Private cImp := .T.

	aImpArq  := {}
	cArq     := ""

	Aadd(aImpArq,{"INFO"      ,"C",1000,0,"C"})     //INFO
	Aadd(aImpArq,{"REC"       ,"N",9999999,0,"C"})  //REC
	Aadd(aImpArq,{"REG"       ,"C",6,0,"C"})        //REGISTRO

	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImporto o arquivo TXT do Sped Fiscal para manipula็ใo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/

	If (Select("MIMPARQ") <> 0)
	dbSelectArea("MIMPARQ")
		dbCloseArea()
	Endif

	cArq := CriaTrab(aImpArq,.T.)
	dbUseArea(.T.,,cArq,"MIMPARQ",.T.,.F.)

    //*******************************************************

    nRec := 0
	Ft_fUse(mv_par01)
	ProcRegua(500)
	While !FT_FEof()
//		IncProc("Aguarde Importa็ใo...")
		IncProc(SUBSTR(FT_FReadLn() ,1,6))
		RecLock("MIMPARQ",.T.)
			MIMPARQ->INFO := FT_FReadLn()
			MIMPARQ->REC  := nRec
			MIMPARQ->REG  := SUBSTR(FT_FReadLn() ,1,6)
		MsUnLock()

		FT_FSkip()

		nRec++
	EndDo
	FT_fUse()

	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFim Importa็ใoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/
	cont := 0
	dbSelectArea("MIMPARQ")
	dbgotop()
	do while !eof() 
	   cont++
	   MIMPARQ->(dbskip())
	enddo

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณaltera    บAutor  ณMicrosiga           บ Data ณ  06/30/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Altera()

dbSelectArea("MIMPARQ")
dbGoTop()
Do While !eof()   
   If SUBSTR(MIMPARQ->INFO,1,6) == "|D100|"  
	   aCampos100 := {}                       
       cBuff  := MIMPARQ->INFO
       PARTE  := ""
       AUXHIST:=SUBSTR(CBUFF,1,LEN(CBUFF)-1)
       POSICAO:=AT("|",AUXHIST)
       CONTADOR:=1     
       While POSICAO > 0                 
	      aadd(aCampos100,ALLTRIM(SUBSTR(AUXHIST,1,POSICAO-1)))            			
          //CAMPOS[CONTADOR]:=ALLTRIM(SUBSTR(AUXHIST,1,POSICAO-1))
          AUXHIST:=SUBSTR(AUXHIST,POSICAO+1,9999)          
          POSICAO:=AT("|",AUXHIST)          
          CONTADOR++
       enddo            
   EndIf
   
   If SUBSTR(MIMPARQ->INFO,1,6) == "|D130|"  
         If aCampos100[18] == "2"         
	         CAMPOS130:= {}
    	     CBUFF := MIMPARQ->INFO
        	 PARTE:=""
	         AUXHIST:=SUBSTR(CBUFF,1,LEN(CBUFF)-1)
    	     POSICAO:=AT("|",AUXHIST)
        	 CONTADOR:=1     
	         while POSICAO > 0                 
				aadd(CAMPOS130,ALLTRIM(SUBSTR(AUXHIST,1,POSICAO-1)))	            			
        	    //CAMPOS[CONTADOR]:=ALLTRIM(SUBSTR(AUXHIST,1,POSICAO-1))
	            AUXHIST:=SUBSTR(AUXHIST,POSICAO+1,9999)          
    	        POSICAO:=AT("|",AUXHIST)          
        	    CONTADOR++
	         enddo                    
	         RecLock("MIMPARQ",.F.)
	            MIMPARQ->INFO := "|" + CAMPOS130[2] + "|" + CAMPOS130[3] + "|" + CAMPOS130[4] + "|" + CAMPOS130[5] + "|" + CAMPOS130[6] + "|" + CAMPOS130[7] +;
	                 "|" + CAMPOS130[8] + "|" + ;
	                CAMPOS130[14] + "|" + CAMPOS130[10] + "|" + CAMPOS130[11] + "|" + CAMPOS130[12] + "|" + CAMPOS130[13]  + "|"+ CAMPOS130[14]  + "|"+ ;
	                CAMPOS130[15]  + "|"
             MsUnLock()
   
         
         EndIf
             RecLock("MIMPARQ",.F.)          
                MIMPARQ->INFO := SUBSTR(MIMPARQ->INFO,1,36) + "42" + SUBSTR(MIMPARQ->INFO,37,6) + "42" + SUBSTR(MIMPARQ->INFO,43,500)
             MsUnLock()         
   endif
 
         If SUBSTR(MIMPARQ->INFO,1,6) == "|D160|"  .and. len(alltrim(MIMPARQ->INFO)) == 69
            RecLock("MIMPARQ",.F.)
               MIMPARQ->INFO := SUBSTR(MIMPARQ->INFO,1,32) + "42" + SUBSTR(MIMPARQ->INFO,33,31) + "42" + SUBSTR(MIMPARQ->INFO,64,6)
               MsUnLock()
         EndIf

         If SUBSTR(MIMPARQ->INFO,1,6) == "|D160|"  .and. len(alltrim(MIMPARQ->INFO)) == 60
            RecLock("MIMPARQ",.F.)
               MIMPARQ->INFO := SUBSTR(MIMPARQ->INFO,1,32) + "42" + SUBSTR(MIMPARQ->INFO,33,22) + "42" + SUBSTR(MIMPARQ->INFO,55,6)
            MsUnLock()
         EndIf      
         MIMPARQ->(dbskip()) 
ENDDO
      
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX452150 บAutor  ณRodrigo             บ Data ณ  06/30/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Separa็ใo do Registro 0150                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                       

Static Function ImpArq()

	Local nCont    := ""
	Local nStatus1 := ""

    nStatus1 := frename(alltrim(mv_par01) , alltrim(mv_par01) + "_old" )
    IF nStatus1 == -1
       MsgStop('Falha na opera็ใo 1 : FError '+str(ferror(),4))
    Endif

   	cArquivo := ALLTRIM(mv_par01)  
	nHandle  := 0

	If !File(cArquivo)
		nHandle := MSFCreate(cArquivo)
	Else
		fErase(cArquivo)
		nHandle := MSFCreate(cArquivo)
	Endif
//    alert("entrou no imparq")
    cLinha := ""
 	dbSelectArea("MIMPARQ")
	dbgotop()
	While !Eof()
		cLinha := ALLTRIM(MIMPARQ->INFO) + chr(13)+chr(10)
		FWrite(nHandle,cLinha,Len(cLinha))
	    MIMPARQ->(dbskip())
	EndDo

	fClose(nHandle)

Return()