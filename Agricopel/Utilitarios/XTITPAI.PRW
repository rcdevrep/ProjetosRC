#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XTITPAI   ºAutor  ³Osmar Schimitberger º Data ³  12/09/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para atualizar os campos E1_TITPAI, E2_TITPAI     º±±
±±º          ³ e FJU_TITPAI - aumento campo prefixo de 3 para 5 caracretesº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AGRICOPEL                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

user function XTITPAI()

SetPrvt("nQuant1,nQuant2,nQuant3,nQuant4")

nQuant1 := 0
nQuant2 := 0
nQuant3 := 0

Processa({|| RunProc1()}, "Atualizando campo E1_TITPAI......")
Processa({|| RunProc2()}, "Atualizando campo E2_TITPAI......")
Processa({|| RunProc3()}, "Atualizando campo FJU_TITPAI......")

Apmsginfo("Titulos Atualizados SE1: " + str(nQuant1,6)  + "      Titulos Atualizado SE2: " + str(nQuant2,6) + "      Titulos Atualizado FJU: " + str(nQuant3,6)) 
Apmsginfo("Processamento Encerrado") 

Return

//***********************************************************************************************************//

Static Function RunProc1()

Local cNumTitPai:= ""

Dbselectarea("SE1")
Dbgotop()
ProcRegua(RecCount())

While !eof()

    //msginfo("achei")
	IncProc("Titulo nr.: " + SE1->E1_NUM)

    If !Empty(SE1->E1_TITPAI) .and. SUBSTR(SE1->E1_TITPAI,4,2) <> "  "               

    
//01I000000675   NF 04590 01                        
//01I  000000675   NF 04590 01                        

        cNumTitPai:= SUBSTR(SE1->E1_TITPAI,1,3)+SPACE(2)+SUBSTR(SE1->E1_TITPAI,4,23) 
                        
		Reclock("SE1",.F.)
	    SE1->E1_TITPAI:= cNumTitPai 
		MsunLock()
		++nQuant1
	
	Endif
	
	Dbselectarea("SE1")
	Dbskip()
Enddo

Return 

Static Function RunProc2()

Local cNumTitPai:= ""

Dbselectarea("SE2")
Dbgotop()
ProcRegua(RecCount())

While !eof()

	IncProc("Titulo nr.: " + SE2->E2_NUM)

    If !Empty(SE2->E2_TITPAI) .and. SUBSTR(SE2->E2_TITPAI,4,2) <> "  "                

        //01I004887 NF 00167601                             
        //01I  004887 NF 00167601
                             
        cNumTitPai:= SUBSTR(SE2->E2_TITPAI,1,3)+SPACE(2)+SUBSTR(SE2->E2_TITPAI,4,23)
                        
		Reclock("SE2",.F.)
	    SE2->E2_TITPAI:= cNumTitPai 
		MsunLock()
		++nQuant2
	
	Endif
	
	Dbselectarea("SE2")
	Dbskip()
Enddo

Return

Static Function RunProc3()

Local cNumTitPai:= ""

Dbselectarea("FJU")
Dbgotop()
ProcRegua(RecCount())

While !eof()

	IncProc("Titulo nr.: " + FJU->FJU_NUM)

    If !Empty(FJU->FJU_TITPAI) .and. SUBSTR(FJU->FJU_TITPAI,4,2) <> "  "             

        //FJU
        //09I000001316   NF 01418701                                               
        //09I  000001316   NF 01418701                        
                       
        cNumTitPai:= SUBSTR(FJU->FJU_TITPAI,1,3)+SPACE(2)+SUBSTR(FJU->FJU_TITPAI,4,23)
                        
		Reclock("FJU",.F.)
	    FJU->FJU_TITPAI:= cNumTitPai 
		MsunLock()
		++nQuant3
	
	Endif
	
	Dbselectarea("FJU")
	Dbskip()
Enddo

Return                        