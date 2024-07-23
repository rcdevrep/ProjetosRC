#include "rwmake.ch"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGR152    บAutor  ณDeco                บ Data ณ  13/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Desmarca cheques troco para nao emitidos                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AGR152()
**********************

SetPrvt("CPERG,AREGISTROS,I,J")
SetPrvt("NLINHAS,NARQS,NVALOR,NESTRU")
SetPrvt("NCAMPOS,_Y,XCONTEM,NPOS")
SetPrvt("LFAZ,_X,CALIASATU,CALIASDES,LTEM")
SetPrvt("ACAMPOS,NPONTO,CARQTRB,")

cPerg:= "AGR152"
aRegistros := {}
Aadd(aRegistros,{cPerg,"01","Emissao          ?","mv_ch1","D",8,0,0,"G","naovazio()","MV_PAR01","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"02","Cheque de        ?","mv_ch2","C",6,0,0,"G","naovazio()","MV_PAR02","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"03","Cheque ate       ?","mv_ch3","C",6,0,0,"G","naovazio()","MV_PAR03","","","","","","","","","","","","","","","",""})

CriaPerguntas(cPerg,aRegistros)

Pergunte(cPerg,.T.)

Processa( {|| DESMARCA() } )

Return nil

Static Function DESMARCA
***********************

cddmmaa := Substr(Dtos(MV_PAR01),7,2)+'/'+Substr(Dtos(MV_PAR01),5,2)+'/'+Substr(Dtos(MV_PAR01),3,2)


If MsgYesNo('Altera Status Cheques :'+MV_PAR02+ ' ate :'+MV_PAR03+' emissao: '+cddmmaa)

	cQuery := ""
	cQuery += "SELECT R_E_C_N_O_ AS nIdRecno "
	cQuery += "FROM "+RetSqlName("SEF")+" EF (NOLOCK) "
	cQuery += "WHERE EF.D_E_L_E_T_ <> '*' "
	cQuery += "AND EF.EF_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR01)+"' "
	cQuery += "AND EF.EF_NUM  BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "
	cQuery += "AND EF.EF_IMPRESS = 'S' "
	                                          
	If (Select("SEF01") <> 0)
	  	dbSelectArea("SEF01")
	   dbCloseArea()
	Endif       

	TCQuery cQuery NEW ALIAS "SEF01"        
	
	dbSelectArea("SEF01")
	dbGoTop() 
	
	Procregua(Reccount())
	
	cExiste := ''
	
	While !eof() 
	
	   Incproc()
	   
		DbSelectArea("SEF")
		DbGoto(SEF01->nIdRecno)
	   reclock('SEF',.f.)
		SEF->EF_IMPRESS := ' '
		msunlock('SEF')
	   
	   cExiste := 'S'
	
		DbSelectArea("SEF01")
	   dbskip()
	
	End
	
	If cExiste <> 'S'
	   MsgStop ('Nao existem cheques troco para parametros informados!!')
	Else
	   MsgStop ('Cheques de ...'+alltrim(MV_PAR02)+' ate...'+alltrim(MV_PAR03)+' emissao..'+cddmmaa+' Alterados!!')
	Endif
Else
   MsgStop('Status dos Cheques Mantidos!!!!')
EndIf
	
RETURN

Static Function CriaPerguntas(cGrupo,aPer)
****************************************** 

LOCAL lRetu := .T.
LOCAL aReg  := {}
 
DbSelectArea("SX1")
If     (FCount() == 41)
       For _l := 1 to Len(aPer)                                   
   	      Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
	                        aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
	                        aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
	                        aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
	                        aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
                            aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","",""})
       Next _l
Elseif (FCount() == 26)
  	   aReg := aPer
Endif
 
DbSelectArea("SX1")
For _l := 1 to Len(aReg)
    If     !dbSeek(cGrupo+StrZero(_l,02,00))
	       RecLock("SX1",.T.)
           For _m := 1 to FCount()
   	           FieldPut(_m,aReg[_l,_m])
	       Next _m
	       MsUnlock("SX1")
	Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
		   RecLock("SX1",.F.)
		   For _k := 1 to FCount()
		       FieldPut(_k,aReg[_l,_k])
	       Next _k
		   MsUnlock("SX1")
    Endif
Next _l
