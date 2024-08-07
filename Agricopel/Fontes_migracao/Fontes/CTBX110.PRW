#Include "CTBR110.Ch"
#Include "PROTHEUS.Ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBX110  � Autor � Pilar S. Albaladejo   � Data � 09.11.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Diario Geral                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBX110(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function CTBX110()

Local WnRel
Local aCtbMoeda:={}
LOCAL cString	:= "CT2"
LOCAL cDesc1 	:= OemToAnsi(STR0001)  //"Este programa ir� imprimir o Di�rio Geral Modelo 1, de acordo"
LOCAL cDesc2 	:= OemToAnsi(STR0002)  //"com os par�metros sugeridos pelo usuario. Este modelo e ideal"
LOCAL cDesc3	:= OemToAnsi(STR0003)  //"para Plano de Contas que possuam codigos nao muito extensos"
Local Titulo 	:= OemToAnsi(STR0006)				// Emissao do Diario Geral
Local lRet		:= .T.

PRIVATE Tamanho	:= "M"
PRIVATE aReturn 	:= { OemToAnsi(STR0004), 1,OemToAnsi(STR0005), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE nomeprog	:= "CTBX110"
PRIVATE aLinha  	:= { }
PRIVATE nLastKey	:= 0
PRIVATE cPerg   	:= "CTX110"
PRIVATE lCodImp		:= .F.
 
// Verificacao foi removida pois estava dando problema ao abrir o programa
//If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
//	Return
//EndIf

wnrel :="CTBX110"
lCodImp := AjCodImpX1("CTX110","12",0,"mv_par12")

Pergunte("CTX110",.F.)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01  	      	// Data Inicial                          �
//� mv_par02            // Data Final                            �
//� mv_par03            // Moeda?                                �
//� mv_par04			// Set Of Books				    	     �
//� mv_par05			// Tipo Lcto? Real / Orcad / Gerenc / Pre�
//� mv_par06  	        // Pagina Inicial                        �
//� mv_par07            // Pagina Final                          �
//� mv_par08            // Pagina ao Reiniciar                   �
//� mv_par09            // So Livro/Livro e Termos/So Termos     �
//� mv_par10            // Imprime Balancete                     �
//� mv_par11            // Imprime Plano de contas               �
//� mv_par12            // Impr Cod.(Normal/Reduz/Cod.Impress)   � /// VER CT1_CODIMP
//����������������������������������������������������������������
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

If mv_par10 = 1
	Pergunte("CTR040",.T.)
	Pergunte("CTR110",.F.)	
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)		     �
//����������������������������������������������������������������
If !ct040Valid(mv_par04)
	lRet := .F.
Else
	aSetOfBook := CTBSetOf(mv_par04)
EndIf

If lRet
	aCtbMoeda	:= CtbMoeda(mv_par03)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		lRet := .F.
	EndIf	
EndIf

If !lRet	
	Set Filter To
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| CTR110Imp(@lEnd,wnRel,cString,aSetOfBook,aCtbMoeda)})
Return 

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CTR110IMP � Autor � Pilar S. Albaladejo   � Data � 10/11/00 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Impressao do Diario Geral                                  ���
��������������������������������������������������������������������������Ĵ��
��� Sintaxe   � CTR110Imp(lEnd,wnRel,cString,aSetOfBook,aCebMoeda)         ���
��������������������������������������������������������������������������Ĵ��
��� Retorno   � Nenhum                                                     ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
���������������������������������������������������������������������������ű�
���Parametros � ExpL1   - A�ao do Codeblock                                ���
���           � ExpC1   - T�tulo do relat�rio                              ���
���           � ExpC2   - Mensagem                                         ���
���           � ExpA1   - Matriz ref. Config. Relatorio                    ���
���           � ExpA2   - Matriz ref. a moeda                              ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function CTR110Imp(lEnd,WnRel,cString,aSetOfBook,aCtbMoeda)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local CbTxt
Local Cbcont
Local Cabec1		:= OemToAnsi(STR0007)
Local Cabec2		:= Iif (cPaisLoc<>"MEX",OemToAnsi(STR0008),OemToAnsi(STR0020))
Local Titulo		:= ""

Local cPicture
Local cDescMoeda
Local cCodMasc
Local cSeparador	:= ""
Local cMascara
Local cGrupo
Local cLote			:= ""
Local cSubLote		:= ""
Local cDoc			:= ""
Local cCancel		:= OemToAnsi(STR0012)
Local dData			:= Ctod("")
Local dDataAnte 	:= Ctod("")
Local lData			:= .T.
Local lFirst		:= .T.
Local nQuebra		:= 0
Local nTotDiaD		:= 0
Local nTotDiaC		:= 0
Local nTotMesD		:= 0
Local nTotMesC		:= 0
Local nTotDeb		:= 0
Local nTotCred	 	:= 0
Local nDia
Local nMes

Local nTamDeb		:= 15			// Tamanho da coluna de DEBITO
Local nTamCrd		:= 14			// Tamanho da coluna de CREDITO
Local nRecCT2		:= 0

Local nColDeb		:= 102			// Coluna de impressao do DEBITO
Local nColCrd		:= 118			// Coluna de impressao do CREDITO
Local dDataFim		:= mv_par02
Local bPular		:= { || 	CT2->CT2_MOEDLC <> cMoeda .Or.;                    
								CT2->CT2_VALOR = 0 .Or.;
								(CT2->CT2_TPSALD # mv_par05 .And. mv_par05 # "*") }
Local lImpLivro		:=.t., lImpTermos:=.f.								
Local l1StQb	 	:= .T.
Local cFilCT1		:= xFilial("CT1")

Local nPagIni		:= mv_par06
Local nPagFim		:= mv_par07
Local nReinicia		:= mv_par08
Local nBloco		:= 0
Local nBlCount		:= 0
m_pag    := 1

CtbQbPg(.T.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS
								
Private cMoeda

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
cMoeda	:= mv_par03

//��������������������������������������������������������������Ŀ
//� Carregando definicoes para impressao -> Decimais, Picture,   �
//� Mascara da Conta                                             �
//����������������������������������������������������������������
cDescMoeda 	:= aCtbMoeda[2]
nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara := RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf
cPicture 	:= aSetOfBook[4]

Titulo		:= 	OemToAnsi(STR0009) + DTOC(mv_par01) + OemToAnsi(STR0010) +;
				DTOC(mv_par02) + OemToAnsi(STR0011) + cDescMoeda + CtbTitSaldo(mv_par05)

dbSelectAre("CT2")
dbSetOrder(1)
SetRegua(Reccount())
dbSeek(xFilial()+Dtos(mv_par01),.T.)

//��������������������������������������������������������������Ŀ
//� Impressao de Termo / Livro                                   �
//����������������������������������������������������������������
Do Case
	Case mv_par09==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
	Case mv_par09==2 ; lImpLivro:=.t. ; lImpTermos:=.t.
	Case mv_par09==3 ; lImpLivro:=.f. ; lImpTermos:=.t.
EndCase		

While 	lImpLivro .And. !Eof() .and. CT2->CT2_FILIAL == xFilial() .And.;
		DTOS(CT2->CT2_DATA) <= DTOS(mv_par02)

	IF lEnd
		@Prow()+1, 0 PSAY cCancel 
		Exit
	EndIF

	If Eval(bPular)
		dbSkip()
		Loop
	EndIf

	nMes := Month(CT2->CT2_DATA)

	While ! Eof() .And. CT2->CT2_FILIAL == xFilial() .And. ;
		DTOS(CT2->CT2_DATA) <= DTOS(mv_par02) .And.;
		Month(CT2->CT2_DATA) == nMes

		If Eval(bPular)
			dbSkip()
			Loop
		EndIf

		nDia := Day(CT2->CT2_DATA)
		lData:= .T.		
		While !Eof() .And. CT2->CT2_FILIAL == xFilial() .And.;
			DTOS(CT2->CT2_DATA) <= DTOS(mv_par02) .And.;
			Month(CT2->CT2_DATA) == nMes .And. Day(CT2->CT2_DATA) == nDia

			IF lEnd
				@Prow()+1, 0 PSAY cCancel 
				Exit
			EndIF

			IncRegua()

			If Eval(bPular)
				dbSkip()
				Loop
			EndIf
		
			cDoc 		:= CT2->CT2_DOC
			cLote		:= CT2->CT2_LOTE
			cSubLote	:= CT2->CT2_SBLOTE

			// Loop para imprimir mesmo lote / documento / continuacao de historico
			While !Eof() .And. CT2->CT2_FILIAL == xFilial() 		.And.;
								CT2->CT2_DOC == cDoc 				.And.;
								CT2->CT2_LOTE == cLote 			.And.;
								CT2->CT2_SBLOTE == cSubLote 		.And.;
						   DTOS(CT2->CT2_DATA) <= DTOS(mv_par02) 	.And.;
				          Month(CT2->CT2_DATA) == nMes 			.And.;
				            Day(CT2->CT2_DATA) == nDia


				If Eval(bPular)
					dbSkip()
					Loop
				EndIf
			
				If li > 75
					li++
					//	Imprime "a transportar ----->" ao final da pagina
					If !lFirst .And. (nTotDiaD <> 0 .or. nTotDiaC <> 0)
						@li,055 PSAY OemToAnsi(STR0013)						// A transportar
						If nTotDiaD <> 0
							ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
						EndIf
						If nTotDiaC <> 0
							ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
						EndIf                                               
						li++
					EndIF             

					CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. EFETUA QUEBRA
					CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
					// Imprime "de transporte -------->" no inicio da pagina
					If !lFirst .And. (nTotDiaD <> 0 .or. nTotDiaC <> 0)
						li++                 
						@ li, 000 PSAY DTOC(CT2->CT2_DATA)
						@li,055 PSAY OemToAnsi(STR0014)
						If nTotDiaD <> 0
							ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
						EndIf
						If nTotDiaC <> 0
							ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
						EndIf                                               
						li+=2
					EndIF
					lFirst := .F.
				EndIF

				If lData
					li++
					@ li, 000 PSAY DTOC(CT2->CT2_DATA)
					li++
					lData := .F.
				EndIf
				
				If !Empty(CT2->CT2_DEBITO)					/// Se a Conta a Debito estiver preenchida
					dbSelectArea("CT1")
					dbSetOrder(1)
					If MsSeek(cFilCT1+CT2->CT2_DEBITO,.F.)	/// e existir no plano de contas
						If mv_par12 == 2							/// Impressao do Codigo Reduzido
							EntidadeCTB(CT1->CT1_RES,li,00,20,.F.,cMascara,cSeparador)
						ElseIf mv_par12 == 3 .AND. lCodImp 	/// Impressao do Codigo de Impressao (se o campo existir)
							EntidadeCTB(CT1->CT1_CODIMP,li,00,20,.F.,cMascara,cSeparador)
						Else										/// Impressao do Codigo Normal
							EntidadeCTB(CT2->CT2_DEBITO,li,00,20,.F.,cMascara,cSeparador)
						Endif
					Else
						EntidadeCTB(CT2->CT2_DEBITO,li,00,20,.F.,cMascara,cSeparador)						
					Endif
				Endif                              
				
				If !Empty(CT2->CT2_CREDIT)
					dbSelectArea("CT1")
					dbSetOrder(1)
					If MsSeek(cFilCT1+CT2->CT2_CREDIT,.F.)
						If mv_par12 == 2							/// Impressao do Codigo Reduzido
							EntidadeCTB(CT1->CT1_RES,li,21,20,.F.,cMascara,cSeparador)			
						ElseIf mv_par12 == 3 .AND. lCodImp			/// Impressao do Codigo de Impressao (se o campo existir)
							EntidadeCTB(CT1->CT1_CODIMP,li,21,20,.F.,cMascara,cSeparador)
						Else										/// Impressao do Codigo Normal
							EntidadeCTB(CT2->CT2_CREDIT,li,21,20,.F.,cMascara,cSeparador)					
						Endif
					Else
						EntidadeCTB(CT2->CT2_CREDIT,li,21,20,.F.,cMascara,cSeparador)					
					Endif
				Endif
				
        		If cPaisLoc == "CHI"
					@ li, 042 PSAY Substr(CT2->CT2_HIST,1,34)
					@ li, 077 PSAY CT2->CT2_LOTE+CT2->CT2_SBLOTE+" "+CT2->CT2_SEGOFI+CT2->CT2_LINHA
				Else
					@ li, 042 PSAY Substr(CT2->CT2_HIST,1,40)
					@ li, 083 PSAY CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_LINHA
				EndIf					
				nValor := CT2->CT2_VALOR
				If CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3"
					ValorCTB(nValor,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
				EndIf
				If CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3"
					ValorCTB(nValor,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
				EndIf

				If CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3"	
					nTotDeb 	+= CT2->CT2_VALOR
					nTotDiaD	+= CT2->CT2_VALOR
					nTotMesD	+= CT2->CT2_VALOR
				EndIf
				If CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3"
					nTotCred += CT2->CT2_VALOR
					nTotdiaC += CT2->CT2_VALOR
					nTotMesC += CT2->CT2_VALOR
				EndIf
				
				// Procura pelo complemento de historico        
				
				nRecCT2 	:= CT2->(Recno())
				dData		:= CT2->CT2_DATA
				cSeqLan 	:= CT2->CT2_SEQLAN
				cEmpOri 	:= CT2->CT2_EMPORI
				cFilOri	:= CT2->CT2_FILORI
			
				DbSelectArea("CT2")
				DbSetOrder(10)
				If dbSeek(xFilial()+DTOS(dData)+cLote+cSubLote+cDoc+cSeqLan+cEmpOri+cFilOri,.T.)
					dbSkip()
					If CT2->CT2_DC == "4"
						While !Eof() .And. CT2->CT2_FILIAL == xFilial() 	.And.;
   						            Dtos(CT2->CT2_DATA) == DTOS(dData)  .And.;
											CT2->CT2_LOTE       == cLote 		   .And.;
											CT2->CT2_SBLOTE     == cSubLote 	   .And.;
											CT2->CT2_DOC        == cDoc 			.And.;
											CT2->CT2_SEQLAN     == cSeqLan 	   .And.;
											CT2->CT2_EMPORI     == cEmpOri      .And.;
											CT2->CT2_FILORI     == cFilOri      
						   If CT2->CT2_DC == "4" 			
						   	li++
							   @ li, 042 PSAY Substr(CT2->CT2_HIST,1,40)
							   cLinha := CT2->CT2_LINHA
						   EndIf
							dbSkip()
						EndDo	
//						If CT2->CT2_MOEDLC <> '01' 
							dbGoto(nRecCT2)
							dbSetOrder(1)					
							dbSkip()					
//						EndIf						
					Else
   					dbGoto(nRecCT2)
	   				dbSetOrder(1)
		   			dbSkip()			
					EndIf				
				Else         
					dbGoto(nRecCT2)
					dbSetOrder(1)
					dbSkip()			
				EndIf 			
				dbSetOrder(1)
				li++				
		
			EndDo
		EndDO
		If lEnd
			Exit
		Endif	
		IF (nTotDiad+nTotDiac)>0
			li++
			@li,055 PSAY OemToAnsi(STR0015)			// Totais do Dia
			ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
			ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
			nTotDiaD	:= 0
			nTotDiaC	:= 0
			li+=2
		EndIF
	EndDO
	If lEnd
		Exit
	End	
	// Totais do Mes
	IF (nTotMesd+nTotMesc) > 0
		@li,055 PSAY OemToAnsi(STR0016)				// Totais do Mes
		ValorCTB(nTotMesD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
		ValorCTB(nTotMesC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
		nTotMesD := 0
		nTotMesC := 0
		li+=2
	EndIF
EndDO

IF (nTotDiad+nTotDiac)>0 .And. !lEnd
	// Totais do Dia - Ultimo impresso
	li++
	@li,055 PSAY OemToAnsi(STR0015)				// Totais do Dia
	ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
	ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
	li++

	// Totais do Mes - Ultimo impresso
	@li,055 PSAY OemToAnsi(STR0016)  			// Totais do Mes
	ValorCTB(nTotMesD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
	ValorCTB(nTotMesC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
	li++
EndIF

// Total Geral impresso
IF (nTotDeb + nTotCred) > 0 .And. !lEnd
	@li,055 PSAY OemToAnsi(STR0017)				// Total Geral
	ValorCTB(nTotDeb ,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
	ValorCTB(nTotCred,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
EndIF

dbSelectarea("CT2")
dbSetOrder(1)
Set Filter To  

If mv_par10 == 1
	Ctbr040(wnRel)
	Pergunte( "CTR110", .F. )
EndIf
If mv_par11 == 1
	Ctbr010(wnRel,mv_par02,mv_par03)
Endif

If lImpTermos 							// Impressao dos Termos

	Pergunte( "CTR110", .F. )
	
	cArqAbert:=GetMv("MV_LDIARAB")
	cArqEncer:=GetMv("MV_LDIAREN")

	dbSelectArea("SM0")
	aVariaveis:={}

	For i:=1 to FCount()	
		If FieldName(i)=="M0_CGC"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
		Else
            If FieldName(i)=="M0_NOME"
                Loop
            EndIf
			AADD(aVariaveis,{FieldName(i),FieldGet(i)})
		Endif
	Next

	dbSelectArea("SX1")
	dbSeek("CTR110"+"01")

	While SX1->X1_GRUPO=="CTR110"
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})
		dbSkip()
	End

	If !File(cArqAbert)
		aSavSet:=__SetSets()
		cArqAbert:=CFGX024(,"Diario Geral.") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If !File(cArqEncer)
		aSavSet:=__SetSets()
		cArqEncer:=CFGX024(,"Diario Geral.") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqAbert#NIL
		ImpTerm(cArqAbert,aVariaveis,AvalImp(132))
	Endif

	If cArqEncer#NIL
		ImpTerm(cArqEncer,aVariaveis,AvalImp(132))
	Endif	 
Endif

If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
End
MS_FLUSH()

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AjX1CodImp�Autor  �Marcos S. Lobo      � Data �  09/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua o ajuste no grupo de perguntas SX1 caso o campo      ���
���          �CT1_CODIMP esteja criado e em uso.                          ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 - Relat�rios SIGACTB                                   ���
�������������������������������������������������������������������������͹��
���Sintaxe   � cPerg= Codigo do Grupo de Perguntas no SX1                 ���          
���          � cSeq = Codigo da Sequencia da Pergunta Imprime?(Normal/Red)���
���          � nX1Def=Numero da Seq�encia de DEFINE no ComboBox do SX1    ���
���          � cMvPar=Codigo do mv_parXX que ser� utilizado.			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AjCodImpX1(cPerg,cSeq,nX1Def,cMvPar)
Local lUsaCodImp	:= .F.
Local aArea			:= GetArea()
Local cCHAR2CH		:= "123456789abcdefghijklmnopqrstuv"
Local cMVCH			:= cMvPar

If Empty(cPerg) .or. Empty(cSeq)
	Return(lUsaCodImp)
Endif
  
dbSelectArea("SX3")
dbSetOrder(2)
If MsSeek("CT1_CODIMP")	.and. X3Uso(SX3->X3_USADO)				//// SE ENCONTRAR O CODIGO DE IMPRESSAO NO SX3 E ESTIVER EM USO
	lUsaCodImp := .T.											//// USO DO CODIGO DE IMPRESSA ESTAR� HABILITADO
Else
	lUsaCodImp := .F.											//// USO DO CODIGO DE IMPRESSAO ESTARA DESABILITADO
Endif

If nX1Def > 0										/// SE FOR SOMENTE MANUTEN��O DE COMBOBOX
	dbSelectArea("SX1")
	dbSetOrder(1)
	If MsSeek(cPerg+cSeq)
		If lUsaCodImp .and. Empty(&("SX1->X1_DEF"+STRZERO(nX1Def,2)))		/// SE USA E ESTA EM BRANCO
			RecLock("SX1",.F.)
			&("Field->X1_DEF"+STRZERO(nX1Def,2))  		:= SX3->X3_TITULO	/// PREENCHE PARA LIBERAR O USO
			&("Field->X1_DEFSPA"+ALLTRIM(STR(nX1Def)))	:= SX3->X3_TITSPA
			&("Field->X1_DEFENG"+ALLTRIM(STR(nX1Def)))	:= SX3->X3_TITENG
			SX1->(MsUnlock())
		ElseIf !lUsaCodImp .and. !Empty(&("SX1->X1_DEF"+STRZERO(nX1Def,2))) /// SE � USA E NAO EST� VAZIO
			RecLock("SX1",.F.)
			&("Field->X1_DEF"+STRZERO(nX1Def,2))  		:= " "			/// APAGA PARA NAO LIBERAR O USO DO COD.IMPRESSAO
			&("Field->X1_DEFSPA"+ALLTRIM(STR(nX1Def)))	:= " "
			&("Field->X1_DEFENG"+ALLTRIM(STR(nX1Def)))	:= " "
			Field->X1_PRESEL	:= 0
			SX1->(MsUnlock())
		Endif
	Endif
Else                    		/// SE FOR NOVA PERGUNTA NO SX1         
	If Empty(cMvPar)
		RestArea(aArea)
		Return(.F.)
	Endif
	dbSelectArea("SX1")
	dbSetOrder(1)
	If !MsSeek(cPerg+cSeq)							/// SE A PERGUNTA NAO EXISTIR
		cMVCH := "mv_ch"+SubStr(cCHAR2CH,val(SubStr(cMvPar,7,Len(cMvPar)-6)),1)		/// DEFINE A SEQUENCIA DO X1_VARIAVL (MV_CHx) UTILIZADO
		RecLock("SX1",.T.)
		Field->X1_GRUPO		:= cPerg
		Field->X1_ORDEM		:= cSeq
		Field->X1_PERGUNT	:= "Impr Cod. Conta    ?"
		Field->X1_PERSPA	:= "�Impr Cod Cuenta   ?"
		Field->X1_PERENG	:= "Print Account Code ?"                       	
		Field->X1_VARIAVL	:= cMVCH
		Field->X1_TIPO		:= "N"
		Field->X1_TAMANHO	:= 1
		Field->X1_DECIMAL	:= 0
		Field->X1_PRESEL	:= 0
		Field->X1_GSC		:= "C"
		Field->X1_VAR01		:= cMvPar
		Field->X1_DEF01 	:= "Normal"
		Field->X1_DEFSPA1	:= "Normal"
		Field->X1_DEFENG1	:= "Normal"
		Field->X1_DEF02 	:= "Reduzido"
		Field->X1_DEFSPA2	:= "Reducido"
		Field->X1_DEFENG2	:= "Reduced"
		If lUsaCodImp												/// SE CODIGO DE IMPRESSAO ESTIVER EM USO
			Field->X1_DEF03 	:= SX3->X3_TITULO
			Field->X1_DEFSPA3	:= SX3->X3_TITSPA
			Field->X1_DEFENG3	:= SX3->X3_TITENG
		Endif
		SX1->(MsUnlock())
	Else
		If !lUsaCodImp .and. !Empty(SX1->X1_DEF03)	/// SE N�O USAR O CODIGO DE IMPRESSAO E O MESMO NAO ESTIVER VAZIO
			RecLock("SX1",.F.)
			Field->X1_DEF03 	:= ""				/// LIMPA O DEFINE DO COD.IMPRESSAO PARA NAO UTILIZAR
			Field->X1_DEFSPA3	:= ""
			Field->X1_DEFENG3	:= ""
			Field->X1_PRESEL	:= 0
			SX1->(MsUnlock())
		ElseIf Empty(SX1->X1_DEF03)					/// SE USAR E O CODIGO DE IMPRESSAO ESTIVER VAZIO
			RecLock("SX1",.F.)
			Field->X1_DEF03 	:= SX3->X3_TITULO	/// ADICIONA O DEFINE DO COD. IMPRESSAO PARA UTILIZAR
			Field->X1_DEFSPA3	:= SX3->X3_TITSPA
			Field->X1_DEFENG3	:= SX3->X3_TITENG
			SX1->(MsUnlock())
		Endif
	Endif
Endif

RestArea(aArea)
Return(lUsaCodImp)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CtbQbPg   �Autor  �Marcos S. Lobo      � Data �  12/02/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Controla a quebra de pagina dos relatorios SIGACTB          ���
���          �quando possuem os parametros de PAG.INICAL-FINAL-REINICIAR  ���
�������������������������������������������������������������������������͹��
���Parametro1� lNewVars  = (.T.=Inicializa variaveis/.F.=Trata Quebra)    ���
���         2� nPagIni 	 = Pagina Inicial do relatorio.               	  ���
���         3� nPagFim 	 = Pagina Final do relatorio               	 	  ���
���         4� nReinicia = Pagina ao Reiniciar do relatorio               ���
���         5� m_pag 	 = Numero da pagina usada na Cabec()              ���
���         6� nBloco    = Bloco de paginas (intervalo de quebra)		  ���
���         7� nBlCount  = Contador de p�ginas (zerado na qebra de bloco) ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CtbQbPg(lNewVars,nPagIni,nPagFim,nReinicia,m_pag,nBloco,nBlCount)

DEFAULT lNewVars := .F.

If lNewVars					/// INICIALIZA AS VARIAVEIS
	nBloco		:= (nPagFim+1) - nPagIni				/// (PAG. FIM + 1) - PAG. INICIAL - BLOCO DE PAG. PARA IMPRESSAO
	nBlCount	:= 0
	m_pag		:= nPagIni
Else						/// NAO INICIALIZA - TRATA A QUEBRA DE PAGINA
	nBlCount++
	If nBlCount > nBloco 							/// SE A QUANTIDADE DE PAGINAS IMPRESSAO FOR IGUAL AO BLOCO DEFINIDO
		If nReinicia > nPagFim						/// SE A PAG. DE REINICIO FOR MAIOR QUE A PAGINA FINAL (ATUAL)
			nUltPg	  := m_pag						/// GUARDA A ULTIMA PAG. IMPRESSA
			m_pag 	  := nReinicia					/// REINICIA A NUMERACAO DE PAG. (m_pag atual ainda n�o foi)
			nPagFim   := nReinicia+nBloco 			/// DEFINE O NOVO NUMERO DA PAGINA FIM
			nReinicia := nPagFim+(nReinicia-nUltPg)	/// DEFINE A PROX. PAG. AO REINICIAR PELA DIFERENCA COM  FINAL
		Else										/// SE A PAG. DE REINICIO FOR MENOR OU IGUAL A PAGINA FINAL                                                                
			m_pag := nReinicia						/// SO REINICIA A NUMERACAO DE PAG.
		Endif
		nBlCount := 1
	EndIf	
Endif

Return