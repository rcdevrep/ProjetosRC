//#INCLUDE "MATA805.ch"
#INCLUDE "PROTHEUS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
//#INCLUDE "protheus.ch"





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MA805Process³ Autor ³ Rodrigo de A. Sartorio³ Data ³13/09/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa a inclusao de saldos por localizacao fisica no SBF³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA805                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AGX466()
// Obtem numero sequencial do movimento
LOCAL cNumSeq:=ProxNum(),i
// Numero do Item do Movimento
Local cCounter	:= '0001'	//StrZero(0,TamSx3('DB_ITEM')[1])   


Private cPerg := "AGX466"


aRegistros := {}
AADD(aRegistros,{cPerg,"01","Produto de ?","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Produto ate ?","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})    
AADD(aRegistros,{cPerg,"03","Documento ?","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Serie     ?","mv_ch4","C",3,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})

U_CriaPer(cPerg,aRegistros)  

Pergunte(cPerg,.T.)

  
/*cQuery := ""
cQuery += "SELECT * "
cQuery += "FROM TMP_BKP,SB8010 B8 "
cQuery += "WHERE D_E_L_E_T_ <> '*'  AND B8_LOCAL = '99' AND B8_LOTECTL = LOTE  AND B8_SALDO > 0 AND CODIGO2 = B8_PRODUTO "
cQuery += "AND  B8_LOCAL = '99' AND B8_SALDO > 0 "   
cQuery += "AND  B8_PRODUTO BETWEEN ' " + mv_par01 + "' AND '" + mv_par02 + "' "      */


cQuery := ""
cQuery += "SELECT * "
cQuery += "FROM SB8010 B8 "
cQuery += "WHERE D_E_L_E_T_ <> '*'  AND B8_LOCAL = '99'  AND B8_SALDO > 0 "
cQuery += "AND  B8_PRODUTO BETWEEN ' " + mv_par01 + "' AND '" + mv_par02 + "' "     



If (Select("QRY") <> 0)
	dbSelectArea("QRY")
	dbCloseArea()
Endif

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "QRY"

dbSelectArea("QRY")
ProcRegua(500)
dbGoTop()
While !Eof()
		cCounter := Soma1(cCounter)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria registro de movimentacao por Localizacao (SDB)           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
		
	  /*	cLote := ""
		cLote := alltrim(str(QRY->LOTE))
		CriaSDB(QRY->CODIGO2,;	// Produto
				'99',;	// Armazem
			    QRY->CONT1,;	// Quantidade
				QRY->ENDERECO,;	// Localizacao
				'',;	// Numero de Serie
				mv_par03,;		// Doc
				mv_par04,;		// Serie
				"",;			// Cliente / Fornecedor
				"",;			// Loja
				"",;			// Tipo NF
				"466",;			// Origem do Movimento
				dDataBase,;		// Data
				cLote,;	// Lote
				"",; // Sub-Lote
				cNumSeq,;		// Numero Sequencial
				"499",;			// Tipo do Movimento
				"M",;			// Tipo do Movimento (Distribuicao/Movimento)
				cCounter,;		// Item
				.F.,;			// Flag que indica se e' mov. estorno
				0,;				// Quantidade empenhado
				0)		// Quantidade segunda UM */
				
					cLote := ""
		cLote := (QRY->B8_LOTECTL)
		CriaSDB(QRY->B8_PRODUTO,;	// Produto
				'99',;	// Armazem
			    QRY->B8_SALDO,;	// Quantidade
				'A01P01N1A01',;	// Localizacao
				'',;	// Numero de Serie
				mv_par03,;		// Doc
				mv_par04,;		// Serie
				"",;			// Cliente / Fornecedor
				"",;			// Loja
				"",;			// Tipo NF
				"466",;			// Origem do Movimento
				dDataBase,;		// Data
				cLote,;	// Lote
				"",; // Sub-Lote
				cNumSeq,;		// Numero Sequencial
				"499",;			// Tipo do Movimento
				"M",;			// Tipo do Movimento (Distribuicao/Movimento)
				cCounter,;		// Item
				.F.,;			// Flag que indica se e' mov. estorno
				0,;				// Quantidade empenhado
				0)		// Quantidade segunda UM
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma saldo em estoque por localizacao fisica (SBF)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GravaSBF("SDB")
		dbSelectArea("QRY")
		QRY->(dbSkip())
EndDo         
Alert("Procedimento Realizado com Sucesso!")
Return()




