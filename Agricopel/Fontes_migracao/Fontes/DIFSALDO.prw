#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 21/02/01
#include "Protheus.ch"
#include "Topconn.ch"

#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF	

User Function DIFSALDO()        // incluido pelo assistente de conversao do AP5 IDE em 16/02/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("ARETURN,CBTXT,CDESC1,CDESC2,CCABEC1,CCABEC2")
SetPrvt("CTITULO,CSTRING,CRODATXT,CNOMEPRG,NTIPO,NTAMANHO")
SetPrvt("NLASTKEY,NCNTIMPR,LABORTPRIN,WNREL,AIMP,ALOCAIS")
SetPrvt("ALOTESLOTE,AQUANTSB2T,ACLASSSB2T,AEMPENSB2T,AQUANTSB8T,ACLASSSB8T")
SetPrvt("AEMPENSB8T,AQUANTSBFT,ACLASSSBFT,AEMPENSBFT,CCOD,CLOCAL")
SetPrvt("CLOTECTL,CNUMLOTE,CARQSDA,CFILSB1,CSEEKSB2,CSEEKSB8")
SetPrvt("CSEEKSBF,CSEEKSDA,CPICTQUANT,CTIPODIF,CRASTRO,CLOCALIZA")
SetPrvt("LLOCALIZA,LRASTRO,LRASTROS,LIMPEMP,NX,NINDSDA")
SetPrvt("NQUANTSB2,NCLASSSB2,NEMPENSB2,NQUANTSB8,NCLASSSB8,NEMPENSB8")
SetPrvt("NQUANTSBF,NCLASSSBF,NEMPENSBF,NTOTREGS,NMULT,NPOSANT")
SetPrvt("NPOSATU,NPOSCNT,LI,M_PAG,NQUANTSB8T,NCLASSSB8T")
SetPrvt("NEMPENSB8T,NQUANTSBFT,NCLASSSBFT,NEMPENSBFT,NY,ATMP")
SetPrvt("NPOS,")


#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 16/02/01 ==> 	#DEFINE PSAY SAY
#ENDIF	
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � DIFSALDO � Autor � Fernando Joly Siquini � Data �07/11/2000낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Verifica Diferen놹s de Saldo entre SB2 x SB8 x SBF         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � SIGAEST                                                    낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     낢�
굇쳐컴컴컴컴컴컴컫컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   낢�
굇쳐컴컴컴컴컴컴컵컴컴컴컴탠컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�              �        �      �                                        낢�
굇읕컴컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/

//-- Variaveis Gern굍icas
aReturn    := {'Zebrado', 1,'Administra뇙o', 2, 2, 1, '',1}
cbTxt      := ''
cDesc1     := 'O objetivo deste relat줿io � exibir detalhadamente todas as diferen놹s'
cDesc2     := 'de Saldo entre os arquivos SB2 x SB8 x SBF.'
cCabec1    := ''
cCabec2    := ''
cTitulo    := 'RELACAO DE DIFERENCAS SB2xSB8xSBF'
cString    := 'SB1'
cRodaTxt   := ''
cNomePrg   := 'DIFSALDO'
nTipo      := 18
nTamanho   := 'G'
nLastKey   := 0
nCntImpr   := 0
lAbortPrin := .F.
WnRel      := 'DIFSALDO'



//-- Envia o Controle para a funcao SETPRINT
WnRel:=SetPrint(cString,WnRel,,@cTitulo,cDesc1,cDesc2,'',.F.,'')

#IFNDEF WINDOWS
	Inkey()
	nLastKey := LastKey()
#ENDIF
If nLastKey == 27
	Return Nil
Endif
SetDefault(aReturn,cString)
#IFNDEF WINDOWS
	Inkey()
	nLastKey := LastKey()
#ENDIF
If nLastKey == 27
	Return Nil
Endif 
   CONOUT("ANTES RPTSTATUS")
#IFDEF WINDOWS
	RptStatus({|| _DIFSALDO()},cTitulo)// Substituido pelo assistente de conversao do AP5 IDE em 16/02/01 ==> 	RptStatus({|| Execute(_DIFSALDO)},cTitulo)
	#ENDIF
// Substituido pelo assistente de conversao do AP5 IDE em 16/02/01 ==> 	__Return()
Return()        // incluido pelo assistente de conversao do AP5 IDE em 16/02/01

// Substituido pelo assistente de conversao do AP5 IDE em 16/02/01 ==> 	Function _DIFSALDO
Static Function _DIFSALDO()


//-- Variaveis Especificas
aImp       := {}
aLocais    := {}
aLoteSLote := {}
aQuantSB2t := {}
aClassSB2t := {}
aEmpenSB2t := {}
aQuantSB8t := {}
aClassSB8t := {}
aEmpenSB8t := {}
aQuantSBFt := {}
aClassSBFt := {}
aEmpenSBFt := {}
cCod       := ''
cLocal     := ''
cLoteCtl   := ''
cNumLote   := ''
cArqSDA    := ''
cFilSB1    := xFilial('SB1')
cSeekSB2   := ''
cSeekSB8   := ''
cSeekSBF   := ''
cSeekSDA   := ''
cPictQuant := PesqPict('SB2','B2_QATU',12)
cTipoDif   := ''
cRastro    := ''
cLocaliza  := ''
lLocaliza  := .F.
lRastro    := .F.
lRastroS   := .F.
lImpEmp    := .F.
nX         := 0
nIndSDA    := 0
nQuantSB2  := 0
nClassSB2  := 0
nEmpenSB2  := 0
nQuantSB8  := 0
nClassSB8  := 0
nEmpenSB8  := 0
nQuantSBF  := 0
nClassSBF  := 0
nEmpenSBF  := 0

//-- Variaveis de Controle de Impressao
nTotRegs   := 0
nMult      := 1
nPosAnt    := 4
nPosAtu    := 4
nPosCnt    := 0
Li         := 80
m_Pag      := 01
nTipo      := If(aReturn[4]==1,15,18)


cPerg := "AGX490"
aRegistros := {}
AADD(aRegistros,{cPerg,"01","Produto de   ?","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Produto ate  ?","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Armazem de   ?","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Armazem ate  ?","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})

U_CriaPer(cPerg,aRegistros)

If !Pergunte(cPerg,.T.)
	Return()
EndIf                          

cQuery := "" 
cQuery := "SELECT B1_COD,B1_LOCPAD FROM " + RetSqlName("SB1") 
cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' " 
cQuery += "  AND B1_COD BETWEEN '"  + mv_par01 + "' AND '"  +  mv_par02 + "'  "  
cQuery += "  AND B1_LOCPAD BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'  "  
cQuery += "  AND D_E_L_E_T_ <> '*' " 



If (Select("QRYSB1") <> 0)
	DbSelectArea("QRYSB1")
	DbCloseArea()
EndIf

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "QRYSB1"

           
CONOUT("ENTROU NO _STATFIS") 


If GetNewPar('MV_DIFSEMP','N')=='S'
	lImpEmp := (Aviso('DIFSALDO','Imprime Diferencas de Empenhos/Reservas? (Padrao=Nao)',{'Nao','Sim'})==2)
EndIf	

//-- Monta os Cabecalhos
cCabec1 := '                                                                                                          _______QUANTIDADE EM ESTOQUE_______    _____QUANTIDADE A CLASSIFICAR_____  '
cCabec2 := 'PRODUTO          LOCAL RASTRO? LOCALIZA? LOTE       SUB-LOTE       TIPO DA DIFERENCA                      QUANT_SB2    QUANT_SB8    QUANT_SBF    CLASS_SB2    CLASS_SB8    CLASS_SBF '
If lImpEmp
	cCabec1 := cCabec1 + '___QUANTIDADE EMPENHADA/RESERVADA____'
	cCabec2 := cCabec2 + 'EMP/RES_SB2  EMP/RES_SB8  EMP/RES_SBF'
EndIf	
//--        XXXXXXXXXXXXXXX  XX    XXXXXXX XXXXXXX   XXXXXXXXXX XXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999999999999 999999999999 999999999999 999999999999 999999999999 999999999999 999999999999 999999999999 999999999999
//--        0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//--        01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

//-- Abertura dos Arquivos e Indices utilizados no Programa
dbSelectArea('SDA')
dbSetOrder(1)
If GetMV('MV_RASTRO')=='S'
	cArqSDA := CriaTrab('', .F.)
	IndRegua('SDA', cArqSDA, 'DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_LOTECTL+DA_NUMLOTE',,, 'Selecionando Registros...')
	nIndSDA := RetIndex('SDA')
	#IFNDEF TOP
		dbSetIndex(cArqSDA+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndSDA+1)	
	dbGoTop()
EndIf	

dbSelectArea('SBF')
dbSetOrder(2)

dbSelectArea('SB8')
dbSetOrder(3)

dbSelectArea('SB2')
dbSetOrder(1)



//-- Inicia a Regua de Relatorio
SetRegua(LastRec())



//-- Varre todo o SB1                               





dbSelectArea("QRYSB1")
dbGotop()
Do While !eof()

	dbSelectArea('SB1')
	dbSetOrder(1)
    dbSeek(xFilial("SB1")+QRYSB1->B1_COD)

    CONOUT(SB1->B1_COD)
	//-- Verifica se houve interrup뇙o pelo operador
	#IFNDEF WINDOWS
		Inkey()
		lAbortPrin := (LastKey()==286)
	#ENDIF
	If lAbortPrin
		Exit
	Endif
	
	//-- Processa a Regua de Relatorio
	IncRegua()
	
	//-- Executa a validacao do filtro do usuario
	If !Empty(aReturn[7]) .And. !&(aReturn[7])
		dbSkip()
		Loop
	EndIf

	cCod      := B1_COD
	lRastro   := Rastro(B1_COD)
	lRastroS  := Rastro(B1_COD, 'S')
	lLocaliza := Localiza(B1_COD)
	If lRastro .Or. lLocaliza
		
		//-- Verifica em quais Locais o Saldo deve ser Analisado
		aLocais := {}
		dbSelectArea('SB2')
		If dbSeek(cSeekSB2:=xFilial('SB2')+cCod, .F.)
			Do While !Eof() .And. cSeekSB2==B2_FILIAL+B2_COD
				If aScan(aLocais, B2_LOCAL)==0
					aAdd(aLocais, B2_LOCAL)
				EndIf
				dbSkip()
			EndDo
		EndIf		
		If lLocaliza
			dbSelectArea('SBF')
			If dbSeek(cSeekSBF:=xFilial('SBF')+cCod, .F.)
				Do While !Eof() .And. cSeekSBF==BF_FILIAL+BF_PRODUTO
					If aScan(aLocais, BF_LOCAL)==0
						aAdd(aLocais, BF_LOCAL)
					EndIf
					dbSkip()
				EndDo
			EndIf		
		EndIf
		If lRastro
			dbSelectArea('SB8')
			If dbSeek(cSeekSB8:=xFilial('SB8')+cCod, .F.)
				Do While !Eof() .And. cSeekSB8==B8_FILIAL+B8_PRODUTO
					If aScan(aLocais, B8_LOCAL)==0
						aAdd(aLocais, B8_LOCAL)
					EndIf
					dbSkip()
				EndDo
			EndIf		
		EndIf
		
		For nX := 1 to Len(aLocais)
			
			cLocal     := aLocais[nX]
			nQuantSB8t := 0
			nClassSB8t := 0
			nEmpenSB8t := 0
			nQuantSBFt := 0
			nClassSBFt := 0
			nEmpenSBFt := 0
			
			//-- Compoe o Saldo no SB2 por Produto+Local
			nQuantSB2 := 0
			nClassSB2 := 0
			nEmpenSB2 := 0
			dbSelectArea('SB2')
			If dbSeek(cSeekSB2:=xFilial('SB2')+cCod+cLocal, .F.)	
				Do While !Eof() .And. cSeekSB2==B2_FILIAL+B2_COD+B2_LOCAL
					nQuantSB2 := nQuantSB2+B2_QATU
					nClassSB2 := nClassSB2+B2_QACLASS
					nEmpenSB2 := nEmpenSB2+(B2_QEMP+B2_RESERVA)
					dbSkip()
				EndDo
			EndIf	
			
			If lLocaliza
				nQuantSBF := 0
				nClassSBF := 0
				nEmpenSBF := 0
				nQuantSB8 := 0
				nClassSB8 := 0
				nEmpenSB8 := 0
				dbSelectArea('SBF')
				If dbSeek(cSeekSBF:=xFilial('SBF')+cCod+cLocal, .F.)
					aLoteSLote := {}
					Do While !Eof() .And. cSeekSBF == BF_FILIAL+BF_PRODUTO+BF_LOCAL
						nQuantSBF := 0
						nClassSBF := 0
						nEmpenSBF := 0
						If lRastro
							cLoteCtl  := BF_LOTECTL
							cNumLote  := BF_NUMLOTE
							If (aScan(aLoteSLote, {|x| x[1]==cLoteCtl.And.If(lRastroS,x[2]==cNumLote,.T.)}))==0
								aAdd(aLoteSLote, {cLoteCtl,cNumLote})
							EndIf
							nQuantSB8 := 0
							nClassSB8 := 0
							nEmpenSB8 := 0
							If Empty(cLoteCtl+cNumLote)
								dbSkip()
								Loop
							EndIf
							//-- Compoe o Saldo no SBF por Produto+Local+Lote+SubLote
							Do While !Eof() .And. cSeekSBF+cLoteCtl+cNumLote==BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE
								nQuantSBF := nQuantSBF+BF_QUANT
								nEmpenSBF := nEmpenSBF+BF_EMPENHO
								dbSkip()
							EndDo
							//-- Compoe o Saldo no SDA por Produto+Local+Lote+SubLote
							dbSelectArea('SDA')
							If dbSeek(cSeekSDA:=xFilial('SDA')+cCod+cLocal+cLoteCtl+cNumLote, .F.)
								Do While !Eof() .And. cSeekSDA==DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_LOTECTL+DA_NUMLOTE
									nQuantSBF := nQuantSBF+DA_SALDO
									nClassSBF := nClassSBF+DA_SALDO									
									dbSkip()
								EndDo							
							EndIf
							nQuantSBFt := nQuantSBFt+nQuantSBF
							nClassSBFt := nClassSBFt+nClassSBF
							nEmpenSBFt := nEmpenSBFt+nEmpenSBF
							//-- Compoe o Saldo no SB8 por Produto+Local+Lote+SubLote
							dbSelectArea('SB8')
							If dbSeek(cSeekSB8:=xFilial('SB8')+cCod+cLocal+cLoteCtl+If(lRastroS,cNumLote,''), .F.)
								Do While !Eof() .And. cSeekSB8==B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+If(lRastroS,B8_NUMLOTE,'')
									nQuantSB8 := nQuantSB8+B8_SALDO
									nClassSB8 := nClassSB8+B8_QACLASS
									nEmpenSB8 := nEmpenSB8+B8_EMPENHO
									dbSkip()
								EndDo	
								nQuantSB8t := nQuantSB8t+nQuantSB8
								nClassSB8t := nClassSB8t+nClassSB8
								nEmpenSB8t := nEmpenSB8t+nEmpenSB8
							EndIf
							//-- Diferen놹 entre SBFxSB8
							cTipoDif := 'B8xBF'	
							_AddImp()
						Else
							//-- Compoe o Saldo no SBF por Produto+Local
							Do While !Eof() .And. cSeekSBF==BF_FILIAL+BF_PRODUTO+BF_LOCAL
								nQuantSBF := nQuantSBF+BF_QUANT
								nEmpenSBF := nEmpenSBF+BF_EMPENHO
								dbSkip()
							EndDo
							//-- Compoe o Saldo no SDA por Produto+Local
							dbSelectArea('SDA')
							If dbSeek(cSeekSDA:=xFilial('SDA')+cCod+cLocal, .F.)
								Do While !Eof() .And. cSeekSDA==DA_FILIAL+DA_PRODUTO+DA_LOCAL
									nQuantSBF := nQuantSBF+DA_SALDO
									nClassSBF := nClassSBF+DA_SALDO									
									dbSkip()
								EndDo							
							EndIf
							nQuantSBFt := nQuantSBFt+nQuantSBF
							nClassSBFt := nClassSBFt+nClassSBF
							nEmpenSBFt := nEmpenSBFt+nEmpenSBF
						EndIf					
						dbSelectArea('SBF')
					EndDo
					//-- Procura por Lotes/SubLotes no SB8 n�o registrados no SBF
					If lRastro .And. SB8->(dbSeek(cSeekSB8:=xFilial('SB8')+cCod+cLocal, .F.))
						//-- Produtos sem movimenta눯o no SBF
						dbSelectArea('SB8')
						Do While !Eof() .And. cSeekSB8==B8_FILIAL+B8_PRODUTO+B8_LOCAL
							nQuantSB8 := 0
							nClassSB8 := 0
							nEmpenSB8 := 0
							cLoteCtl  := B8_LOTECTL
							cNumLote  := B8_NUMLOTE
							If !(aScan(aLoteSLote, {|x| x[1]==cLoteCtl.And.If(lRastroS,x[2]==cNumLote,.T.)}))==0
								dbSkip()
								Loop
							EndIf
							If Empty(cLoteCtl+cNumLote)
								dbSkip()
								Loop
							EndIf
							//-- Compoe o Saldo no SB8 por Produto+Local+Lote+SubLote
							Do While !Eof() .And. cSeekSB8+cLoteCtl+If(lRastroS,cNumLote,'')==B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+If(lRastroS,B8_NUMLOTE,'')
								nQuantSB8 := nQuantSB8+B8_SALDO
								nClassSB8 := nClassSB8+B8_QACLASS
								nEmpenSB8 := nEmpenSB8+B8_EMPENHO
								dbSkip()
							EndDo
							nQuantSB8t := nQuantSB8t+nQuantSB8
							nClassSB8t := nClassSB8t+nClassSB8
							nEmpenSB8t := nEmpenSB8t+nEmpenSB8
							nQuantSBF  := 0
							nClassSBF  := 0
							nEmpenSBF  := 0
							//-- Compoe o Saldo no SDA por Produto+Local+Lote+SubLote
							dbSelectArea('SDA')
							If dbSeek(cSeekSDA:=xFilial('SDA')+cCod+cLocal+cLoteCtl+If(lRastroS,cNumLote,''), .F.)
								Do While !Eof() .And. cSeekSDA==DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_LOTECTL+If(lRastroS,DA_NUMLOTE,'')
									nQuantSBF := nQuantSBF+DA_SALDO
									nClassSBF := nClassSBF+DA_SALDO									
									dbSkip()
								EndDo							
							EndIf
							nQuantSBFt := nQuantSBFt+nQuantSBF
							nClassSBFt := nClassSBFt+nClassSBF
							nEmpenSBFt := nEmpenSBFt+nEmpenSBF
							//-- Diferen놹 entre SBFxSB8
							cTipoDif := 'B8xBF'	
							_AddImp()							
							dbSelectArea('SB8')
						EndDo
					EndIf
				ElseIf lRastro .And. SB8->(dbSeek(cSeekSB8:=xFilial('SB8')+cCod+cLocal, .F.))
					//-- Produtos sem movimenta눯o no SBF
					dbSelectArea('SB8')
					Do While !Eof() .And. cSeekSB8==B8_FILIAL+B8_PRODUTO+B8_LOCAL
						nQuantSB8 := 0
						nClassSB8 := 0
						nEmpenSB8 := 0
						cLoteCtl  := B8_LOTECTL
						cNumLote  := B8_NUMLOTE
						If Empty(cLoteCtl+cNumLote)
							dbSkip()
							Loop
						EndIf
						//-- Compoe o Saldo no SB8 por Produto+Local+Lote+SubLote
						Do While !Eof() .And. cSeekSB8+cLoteCtl+If(lRastroS,cNumLote,'')==B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+If(lRastroS,B8_NUMLOTE,'')
							nQuantSB8 := nQuantSB8+B8_SALDO
							nClassSB8 := nClassSB8+B8_QACLASS
							nEmpenSB8 := nEmpenSB8+B8_EMPENHO
							dbSkip()
						EndDo
						nQuantSB8t := nQuantSB8t+nQuantSB8
						nClassSB8t := nClassSB8t+nClassSB8
						nEmpenSB8t := nEmpenSB8t+nEmpenSB8
						nQuantSBF  := 0
						nClassSBF  := 0
						nEmpenSBF  := 0
						//-- Compoe o Saldo no SDA por Produto+Local+Lote+SubLote
						dbSelectArea('SDA')
						If dbSeek(cSeekSDA:=xFilial('SDA')+cCod+cLocal+cLoteCtl+If(lRastroS,cNumLote,''), .F.)
							Do While !Eof() .And. cSeekSDA==DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_LOTECTL+If(lRastroS,DA_NUMLOTE,'')
								nQuantSBF := nQuantSBF+DA_SALDO
								nClassSBF := nClassSBF+DA_SALDO									
								dbSkip()
							EndDo							
						EndIf
						nQuantSBFt := nQuantSBFt+nQuantSBF
						nClassSBFt := nClassSBFt+nClassSBF
						nEmpenSBFt := nEmpenSBFt+nEmpenSBF
						//-- Diferen놹 entre SBFxSB8
						cTipoDif := 'B8xBF'	
						_AddImp()							
						dbSelectArea('SB8')
					EndDo
				Else
					//-- Verifica no SDA Saldos Ainda N�o Distribuidos
					dbSelectArea('SDA')
					If dbSeek(cSeekSDA:=xFilial('SDA')+cCod+cLocal, .F.)
						Do While !Eof() .And. cSeekSDA==DA_FILIAL+DA_PRODUTO+DA_LOCAL
							nQuantSBF := 0
							nClassSBF := 0
							nEmpenSBF := 0
							//-- Compoe o Saldo por Produto+Local
							Do While !Eof() .And. cSeekSDA==DA_FILIAL+DA_PRODUTO+DA_LOCAL
								nQuantSBF := nQuantSBF+DA_SALDO
								nClassSBF := nClassSBF+DA_SALDO									
								dbSkip()
							EndDo							
							nQuantSBFt := nQuantSBFt+nQuantSBF
							nClassSBFt := nClassSBFt+nClassSBF
							nEmpenSBFt := nEmpenSBFt+nEmpenSBF
							dbSelectArea('SDA')
						EndDo
					EndIf	
				EndIf
				nQuantSB8 := nQuantSB8t
				nClassSB8 := nClassSB8t
				nEmpenSB8 := nEmpenSB8t
				nQuantSBF := nQuantSBFt
				nClassSBF := nClassSBFt
				nEmpenSBF := nEmpenSBFt
				If lRastro
					//-- Diferen놹 entre SB8xSB2
					cLoteCtl  := ''
					cNumLote  := ''
					cTipoDif  := 'B2xB8'	
					_AddImp()
				EndIf
				//-- Diferen놹 entre SBFxSB2
				cLoteCtl := ''
				cNumLote := ''
				cTipoDif := 'B2xBF'	
				_AddImp()
			ElseIf lRastro
				nQuantSB8 := 0
				nClassSB8 := 0
				nEmpenSB8 := 0
				dbSelectArea('SB8')
				If dbSeek(cSeekSB8:=xFilial('SB8')+cCod+cLocal, .F.)
					Do While !Eof() .And. cSeekSB8==B8_FILIAL+B8_PRODUTO+B8_LOCAL
						cLoteCtl  := B8_LOTECTL
						cNumLote  := If(lRastroS,B8_NUMLOTE,'')
						nQuantSB8 := 0
						nClassSB8 := 0
						nEmpenSB8 := 0
						//-- Compoe no SB8 o Saldo por Produto+Local+Lote+SubLote
						Do While !Eof() .And. cSeekSB8+cLoteCtl+cNumLote==B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+If(lRastroS,B8_NUMLOTE,'')
							nQuantSB8 := nQuantSB8+B8_SALDO
							nClassSB8 := nClassSB8+B8_QACLASS
							nEmpenSB8 := nEmpenSB8+B8_EMPENHO
							dbSkip()
						EndDo
						nQuantSB8t := nQuantSB8t+nQuantSB8
						nClassSB8t := nClassSB8t+nClassSB8
						nEmpenSB8t := nEmpenSB8t+nEmpenSB8
					EndDo
					nQuantSB8 := nQuantSB8t
					nClassSB8 := nClassSB8t
					nEmpenSB8 := nEmpenSB8t
					nQuantSBF := nQuantSBFt
					nClassSBF := nClassSBFt
					nEmpenSBF := nEmpenSBFt
					//-- Diferen놹 entre SB8xSB2
					cLoteCtl := ''
					cNumLote := ''
					cTipoDif := 'B2xB8'	
					_AddImp()
				EndIf
			EndIf
		Next nX	
	EndIf	
	dbSelectArea("QRYSB1")
	QRYSB1->(dbSkip())
EndDo	

//-- Impress�o dos Dados
For nX := 1 to Len(aImp)
	aSort(aImp[nX],,,{|x, y| x[1]+x[2]+x[5]+x[6] < y[1]+y[2]+y[5]+y[6]})
	For nY := 1 to Len(aImp[nX])
		lRastro   := aImp[nX, nY,03,1]
		lLocaliza := aImp[nX, nY,04]
		cCod      := aImp[nX, nY, 01]
		cLocal    := aImp[nX, nY, 02]
		cRastro   := If(aImp[nX,nY,03,1],If(aImp[nX,nY,03,2],'SUBLOTE','LOTE'),'NAO')
		cLocaliza := If(aImp[nX,nY,04],'UTILIZA','NAO')
		cLoteCtl  := aImp[nX, nY, 05]
		cNumLote  := aImp[nX, nY, 06]
		cTipoDif  := aImp[nX, nY, 07]
		nQuantSB2 := aImp[nX, nY, 08]
		nQuantSB8 := aImp[nX, nY, 09]
		nQuantSBF := aImp[nX, nY, 10]
		nClassSB2 := aImp[nX, nY, 11]
		nClassSB8 := aImp[nX, nY, 12]
		nClassSBF := aImp[nX, nY, 13]
		nEmpenSB2 := aImp[nX, nY, 14]
		nEmpenSB8 := aImp[nX, nY, 15]
		nEmpenSBF := aImp[nX, nY, 16]
		_ImpDif()		
	Next nY
Next nX

	
//-- Verifica se houve interrup뇙o pelo operador
If lAbortPrin
	@Prow()+1, 001 PSAY 'CANCELADO PELO OPERADOR'
ElseIf Len(aImp)>0 .And. Len(aImp[1])>0
	//-- Impress�o da Legenda
	If Li > 58
		Cabec(cTitulo,cCabec1,cCabec2,cNomePrg,nTamanho,nTipo)
	EndIf
	Li := Li+1
	@Li, 000 PSAY 'INFORMACOES SOBRE OS TIPOS DE DIFERENCA:'
	Li := Li+1
	@LI, 000 PSAY 'Q_ - DIFERENCA DE QUANTIDADES'
	Li := Li+1
	@Li, 000 PSAY 'C_ - DIFERENCA DE QTD A CLASSIFICAR'
	Li := Li+1
	If lImpEmp
		@Li, 000 PSAY 'E_ - DIFERENCA DE QTD EMPENHADA/RESERVADA'
		Li := Li+1
	EndIf	
	@Li, 000 PSAY 'AAxBB - ARQUIVOS ONDE AS DIFERENCAS FORAM ENCONTRADAS'
	Li := Li+1
	@Li, 000 PSAY '        OBS.: O SALDO DO SBF FOI COMPOSTO COM A ADICAO DA QTD DO SDA'
	Li := Li+1
EndIf	

If !(Li==80)
	Roda(nCntImpr, cRodaTxt, nTamanho)
EndIf

Set Device to Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(WnRel)
Endif

MS_Flush()

fErase(cArqSDA+OrdBagExt())

#IFNDEF WINDOWS
// Substituido pelo assistente de conversao do AP5 IDE em 16/02/01 ==> 	__Return()
Return()        // incluido pelo assistente de conversao do AP5 IDE em 16/02/01
#ELSE
	Return Nil
#ENDIF	

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � _AddImp  � Autor � Fernando Joly Siquini � Data �07/11/2000낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Adiciona Dados no Array de Impressao                       낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � SIGAEST                                                    낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     낢�
굇쳐컴컴컴컴컴컴컫컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   낢�
굇쳐컴컴컴컴컴컴컵컴컴컴컴탠컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�              �        �      �                                        낢�
굇읕컴컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
// Substituido pelo assistente de conversao do AP5 IDE em 16/02/01 ==> Function _AddImp
Static Function _AddImp()

aTmp       := {}
nY         := 0
nPos       := 0

If Len(aImp) <= 0 .Or. Len(aImp) >=4095
	aAdd(aImp, {})
EndIf

aTmp := {cCod,;                    //-- 01.Codigo do Produto
	cLocal,;                        //-- 02.Local
	{lRastro,lRastroS},;            //-- 03.Rastro?
	lLocaliza,;                     //-- 04.Localiza?
	If('B2'$cTipoDif,'',cLoteCtl),; //-- 05.Lote
	If('B2'$cTipoDif.Or.!lRastroS,'',cNumLote),; //-- 06.Sub-Lote
	'',;                            //-- 07.Tipo de Diferen놹
	nQuantSB2,;                     //-- 08.Qtd SB2
	nQuantSB8,;                     //-- 09.Qtd SB8
	nQuantSBF,;                     //-- 10.Qtd SBF
	nClassSB2,;                     //-- 11.Class SB2
	nClassSB8,;                     //-- 12.Class SB8
	nClassSBF,;                     //-- 13.Class SBF
	nEmpenSB2,;                     //-- 14.Empen SB2
	nEmpenSB8,;                     //-- 15.Empen SB8
	nEmpenSBF}                      //-- 16.Empen SBF

aTmp[7] := ''
If 'B8xBF' $cTipoDif
	If !(QtdComp(nQuantSBF)==QtdComp(nQuantSB8))
		aTmp[7] := aTmp[7] + If(Empty(aTmp[7]),'','/') + 'Q_'+cTipoDif
	EndIf
	If !(QtdComp(nClassSBF)==QtdComp(nClassSB8))
		aTmp[7] := aTmp[7] + If(Empty(aTmp[7]),'','/') + 'C_'+cTipoDif
	EndIf
	If lImpEmp .And. !(QtdComp(nEmpenSBF)==QtdComp(nEmpenSB8))
		aTmp[7] := aTmp[7] + If(Empty(aTmp[7]),'','/') + 'E_'+cTipoDif
	EndIf
	If !Empty(aTmp[7])
		For nY := 1 to Len(aImp)
			nPos := aScan(aImp[nY], {|x|x[1]==aTmp[1].And.x[2]==aTmp[2].And.x[5]==aTmp[5].And.x[6]==aTmp[6]})
			If nPos > 0
				Exit
			EndIf		
		Next nY
		If nPos > 0 .And. !'B2'$aImp[nY,nPos,7] .And. Len((aImp[nY,nPos,7]+If(Empty(aImp[nY,nPos,7]),'','/')+aTmp[7]))<=35
			aImp[nY,nPos,7] := aImp[nY,nPos,7] + If(Empty(aImp[nY,nPos,7]),'','/') + aTmp[7]
		Else
			aAdd(aImp[Len(aImp)], aClone(aTmp))
		EndIf	
	EndIf	
ElseIf 'B2xB8' $cTipoDif
	If !(QtdComp(nQuantSB8)==QtdComp(nQuantSB2))
		aTmp[7] := aTmp[7] + If(Empty(aTmp[7]),'','/') + 'Q_'+cTipoDif
	EndIf
	If !(QtdComp(nClassSB8)==QtdComp(nClassSB2))
		aTmp[7] := aTmp[7] + If(Empty(aTmp[7]),'','/') + 'C_'+cTipoDif
	EndIf
	If lImpEmp .And. !(QtdComp(nEmpenSB8)==QtdComp(nEmpenSB2))
		aTmp[7] := aTmp[7] + If(Empty(aTmp[7]),'','/') + 'E_'+cTipoDif
	EndIf
	If !Empty(aTmp[7])
		For nY := 1 to Len(aImp)
			nPos := aScan(aImp[nY], {|x|x[1]==aTmp[1].And.x[2]==aTmp[2].And.Empty(x[5]+x[6])})
			If nPos > 0
				Exit
			EndIf		
		Next nY
		If nPos > 0 .And. !'B8xBF'$aImp[nY,nPos,7] .And. Len((aImp[nY,nPos,7]+If(Empty(aImp[nY,nPos,7]),'','/')+aTmp[7]))<=35
			aImp[nY,nPos,7] := aImp[nY,nPos,7] + If(Empty(aImp[nY,nPos,7]),'','/') + aTmp[7]
		Else
			aAdd(aImp[Len(aImp)], aClone(aTmp))
		EndIf	
	EndIf			
ElseIf 'B2xBF' $cTipoDif
	If !(QtdComp(nQuantSBF)==QtdComp(nQuantSB2))
		aTmp[7] := aTmp[7] + If(Empty(aTmp[7]),'','/') + 'Q_'+cTipoDif
	EndIf
	If !(QtdComp(nClassSBF)==QtdComp(nClassSB2))
		aTmp[7] := aTmp[7] + If(Empty(aTmp[7]),'','/') + 'C_'+cTipoDif
	EndIf
	If lImpEmp .And. !(QtdComp(nEmpenSBF)==QtdComp(nEmpenSB2))
		aTmp[7] := aTmp[7] + If(Empty(aTmp[7]),'','/') + 'E_'+cTipoDif
	EndIf
	If !Empty(aTmp[7])
		For nY := 1 to Len(aImp)
			nPos := aScan(aImp[nY], {|x|x[1]==aTmp[1].And.x[2]==aTmp[2].And.Empty(x[5]+x[6])})
			If nPos > 0
				Exit
				EndIf		
		Next nY
		If nPos > 0 .And. !'B8xBF'$aImp[nY,nPos,7] .And. Len((aImp[nY,nPos,7]+If(Empty(aImp[nY,nPos,7]),'','/')+aTmp[7]))<=35
			aImp[nY,nPos,7] := aImp[nY,nPos,7] + If(Empty(aImp[nY,nPos,7]),'','/') + aTmp[7]
		Else
			aAdd(aImp[Len(aImp)], aClone(aTmp))
		EndIf	
	EndIf	
EndIf

Return Nil	

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � _ImpDif  � Autor � Fernando Joly Siquini � Data �07/11/2000낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Imprime Diferen놹s de Saldo entre SB2 x SB8 x SBF          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � SIGAEST                                                    낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     낢�
굇쳐컴컴컴컴컴컴컫컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   낢�
굇쳐컴컴컴컴컴컴컵컴컴컴컴탠컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�              �        �      �                                        낢�
굇읕컴컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
// Substituido pelo assistente de conversao do AP5 IDE em 16/02/01 ==> Function _ImpDif
Static Function _ImpDif()

If Li > 58
	Cabec(cTitulo,cCabec1,cCabec2,cNomePrg,nTamanho,nTipo)
EndIf
@Li, 000 PSAY cCod
@Li, 017 PSAY cLocal
@Li, 023 PSAY cRastro
@Li, 031 PSAY cLocaliza
@Li, 041 PSAY cLoteCtl
@Li, 052 PSAY cNumLote
@Li, 067 PSAY cTipoDif
@Li, 103 PSAY If('Q_'$cTipoDif,If('B2'$cTipoDif,Transform(nQuantSB2, cPictQuant),'            '),If('B2'$cTipoDif,'------------','            '))
@Li, 116 PSAY If('Q_'$cTipoDif,If(lRastro,Transform(nQuantSB8, cPictQuant),'            '),If(lRastro,'------------','            '))
@Li, 129 PSAY If('Q_'$cTipoDif,If(lLocaliza,Transform(nQuantSBF, cPictQuant),'            '),If(lLocaliza,'------------','            '))
@Li, 142 PSAY If('C_'$cTipoDif,If('B2'$cTipoDif,Transform(nClassSB2, cPictQuant),'            '),If('B2'$cTipoDif,'------------','            '))
@Li, 155 PSAY If('C_'$cTipoDif,If(lRastro,Transform(nClassSB8, cPictQuant),'            '),If(lRastro,'------------','            '))
@Li, 168 PSAY If('C_'$cTipoDif,If(lLocaliza,Transform(nClassSBF, cPictQuant),'            '),If(lLocaliza,'------------','            '))
If lImpEmp
	@Li, 181 PSAY If('E_'$cTipoDif,If('B2'$cTipoDif,Transform(nEmpenSB2, cPictQuant),'            '),If('B2'$cTipoDif,'------------','            '))
	@Li, 194 PSAY If('E_'$cTipoDif,If(lRastro,Transform(nEmpenSB8, cPictQuant),'            '),If(lRastro,'------------','            '))
	@Li, 207 PSAY If('E_'$cTipoDif,If(lLocaliza,Transform(nEmpenSBF, cPictQuant),'            '),If(lLocaliza,'------------','            '))
EndIf	

Li := Li+1

Return Nil	
