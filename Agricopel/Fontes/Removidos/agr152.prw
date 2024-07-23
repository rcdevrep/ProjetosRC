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

	Local cPerg:= "AGR152"
	Local aRegistros := {}

	Aadd(aRegistros,{cPerg,"01","Emissao          ?","mv_ch1","D",8,0,0,"G","naovazio()","MV_PAR01","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"02","Cheque de        ?","mv_ch2","C",6,0,0,"G","naovazio()","MV_PAR02","","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"03","Cheque ate       ?","mv_ch3","C",6,0,0,"G","naovazio()","MV_PAR03","","","","","","","","","","","","","","","",""})

	U_CriaPer(cPerg,aRegistros)

	If (Pergunte(cPerg,.T.))
		Processa( {|| Desmarca() } )
	EndIf

Return nil

Static Function Desmarca()

	Local cExiste := ""
	Local cQuery  := ""
	Local cddmmaa := Substr(Dtos(MV_PAR01),7,2)+'/'+Substr(Dtos(MV_PAR01),5,2)+'/'+Substr(Dtos(MV_PAR01),3,2)

	If MsgYesNo('Altera Status Cheques :'+MV_PAR02+ ' ate :'+MV_PAR03+' emissao: '+cddmmaa, "Confirmacao")

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

Return()