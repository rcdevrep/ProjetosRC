#include "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX312   ºAutor  ³RODRIGO             º Data ³  05/25/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ GERAÇÃO ARQUIVO SIMP MIME DISTRIBUIDORA E AGRICOPEL        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function AGX312()
**********************

SetPrvt("CPERG,AREGISTROS,I,J")
SetPrvt("NLINHAS,NARQS,NVALOR,NESTRU")
SetPrvt("NCAMPOS,_Y,XCONTEM,NPOS,NQUANT,NQTD10,NQTD20,NQTD40,NQTD90")
SetPrvt("LFAZ,_X,CALIASATU,CALIASDES,LTEM,CBAIRRO,CCONTA")
SetPrvt("ACAMPOS,ND2QUANT,NPONTO,CARQTRB,CPRODUTO,CINSCR,CCEP,CRESTO1,CRESTO2,CRESTO3,NTOTREG")
SetPrvt("CMMAAAA,CDDMMAAAAi,CDDMMAAAAf,COPERAC,CCOMP,XCERTIFI,CCERTIFI,XCOD,XEMISSAO")

cPerg:= "AGR159"
aRegistros := {}
Aadd(aRegistros,{cPerg,"01","Emissao de       ?","mv_ch1","D",8,0,0,"G","naovazio()","MV_PAR01","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"02","Emissao ate      ?","mv_ch2","D",8,0,0,"G","naovazio()","MV_PAR02","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"03","Data Fech Sld Ini?","mv_ch3","D",8,0,0,"G","naovazio()","MV_PAR03","","","","","","","","","","","","","","","",""})

CriaPerguntas(cPerg,aRegistros)     


Pergunte(cPerg,.T.)

Processa( {|| GERAARQ() } )

Return nil

Static Function Geraarq
***********************

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Registros Saida (SD2) para geracao Arquivo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*cQuery := ""
cQuery += "SELECT * "
cQuery += "FROM "+RetSqlName("SD2")+" (NOLOCK) "
cQuery += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' "
cQuery += "AND D_E_L_E_T_ = '' AND D2_TIPO = 'N' "
cQuery += "AND D2_EMISSAO >= '"+dtos(mv_par01)+"' AND D2_EMISSAO <= '"+dtos(mv_par02)+"' "
cQuery += "AND (D2_TP = 'CO' OR D2_TP = 'GV' OR D2_TP = 'LU') "*/      
  cAgeRegInf := ""     
  cCodInst   := ""
  If SM0->M0_CODIGO == "01"
     cAgeRegInf := '4081632093'
	  if SM0->M0_CODFIL =  "01"
        cCodInst:= '1031729' // Cod Instalacao 1
 	  endif
	  if SM0->M0_CODFIL =  "02"
        cCodInst:= '1031730'  // Cod Instalacao 1
	  endif                        
	  if SM0->M0_CODFIL =  "03"
        cCodInst:= '0158429' // Cod Instalacao 1
     endif
	  if SM0->M0_CODFIL =  "06"
        cCodInst:= '0000000' // Cod Instalacao 1
     endif     
  EndIf                    
  
  /*
  // Mime Distribuidora não existe mais
  If SM0->M0_CODIGO == "02"
     cAgeRegInf := '1001799935'
     Do Case
        Case SM0->M0_CODFIL ==  "01"            
           cCodInst:= '1032183' // Cod Instalacao 1
        Case SM0->M0_CODFIL ==  "03"
           cCodInst:= '1152416'  // Cod Instalacao 1
        Case SM0->M0_CODFIL ==  "04"
	        cCodInst:= '1161300' // Cod Instalacao 1
        Case SM0->M0_CODFIL ==  "05"        
	        cCodInst:= '1161925'   
	        Alert(cCodInst)
	 EndCase
  EndIf
  */
  
  If SM0->M0_CODIGO == "11"
     cAgeRegInf := ""
     cCodInst   := ""

     cAgeRegInf := '4008091710'
	  if SM0->M0_CODFIL =  "01"
        cCodInst:= '1106451' // Cod Instalacao 1
 	  endif
  EndIf   

  If SM0->M0_CODIGO == "12"
     cAgeRegInf := ""
     cCodInst   := ""

     cAgeRegInf := '4001690394'
	  if SM0->M0_CODFIL =  "01"
        cCodInst:= '1000205' // Cod Instalacao 1
 	  endif
  EndIf 

  If SM0->M0_CODIGO == "15"
     cAgeRegInf := ""
     cCodInst   := ""

     cAgeRegInf := '4000179490'
	  If SM0->M0_CODFIL =  "01"
        cCodInst:= '1031951' // Cod Instalacao 1
 	  EndIf
  EndIf  

  cQuery := ""                                                                                                   
  cQuery += "SELECT D2_FILIAL,D2_DOC, D2_SERIE,D2_EMISSAO,D2_CLIENTE,D2_CF,D2_TIPO,D2_LOJA,B1_CODSIMP,SUM(D2_QUANT * B1_VOLSIMP)  AS QUANT "
  cQuery += "FROM "+RetSqlName("SD2") + " (NOLOCK)," + RetSqlName("SB1") + " (NOLOCK) "
  cQuery += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' "
  cQuery += "AND " + RetSqlName("SD2") + ".D_E_L_E_T_ <> '*' AND D2_TIPO = 'N' "
  cQuery += "AND D2_EMISSAO >= '"+dtos(mv_par01)+"' AND D2_EMISSAO <= '"+dtos(mv_par02)+"' "
  cQuery += "AND (D2_TP = 'CO' OR D2_TP = 'GV' OR D2_TP = 'LU') "
  cQuery += "AND " + RetSqlName("SB1") + ".B1_FILIAL = D2_FILIAL "
  cQuery += "AND " + RetSqlName("SB1") + ".B1_COD = D2_COD  "
  cQuery += "AND " + RetSqlName("SB1") + ".D_E_L_E_T_ <> '*' "   
  cQuery += "AND B1_CODSIMP <> '' AND B1_SITUACA = '1'  "
  cQuery += "AND LTRIM(RTRIM(D2_CF)) NOT IN('5663','6663','5657') "  
  cQuery += "GROUP BY D2_FILIAL,D2_DOC, D2_SERIE,D2_EMISSAO,D2_CLIENTE,D2_LOJA,B1_CODSIMP,D2_CF,D2_TIPO "
  cQuery += "ORDER BY D2_FILIAL,D2_DOC, D2_SERIE,D2_EMISSAO,B1_CODSIMP "


  cQuery := ChangeQuery(cQuery)
  If (Select("MSD2") != 0)
     dbSelectArea("MSD2")
     dbCloseArea()
  Endif
  TCQuery cQuery NEW ALIAS "MSD2"
  TCSetField("MSD2","D2_EMISSAO","D",08,0)
 

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Seleciona Registros Entrada (SD1) para geracao Arquivo
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  /*cQuery := ""
cQuery += "SELECT * "
cQuery += "FROM "+RetSqlName("SD1")+" (NOLOCK) "
cQuery += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
cQuery += "AND D_E_L_E_T_ = '' AND D1_TIPO IN ('D','N') "  
cQuery += "AND D1_DTDIGIT >= '"+dtos(mv_par01)+"' AND D1_DTDIGIT <= '"+dtos(mv_par02)+"' "  //ALERADO D1_EMISSAO PARA D1_DIGIT
cQuery += "AND (D1_TP = 'CO' OR D1_TP = 'GV' OR D1_TP = 'LU') "*/


cQuery := ""
cQuery += "SELECT D1_FILIAL,D1_DOC, D1_SERIE,D1_DTDIGIT,D1_FORNECE,D1_LOJA,D1_CF,D1_TIPO,B1_CODSIMP,SUM(D1_QUANT * B1_VOLSIMP)  AS QUANT "
cQuery += "FROM "+RetSqlName("SD1") + "," + RetSqlName("SB1") + " " 
cQuery += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
cQuery += "AND " + RetSqlName("SD1") + ".D_E_L_E_T_ <> '*' AND (D1_TIPO = 'N' OR D1_TIPO = 'D') "
cQuery += "AND D1_DTDIGIT >= '"+dtos(mv_par01)+"' AND D1_DTDIGIT <= '"+dtos(mv_par02)+"' "
cQuery += "AND (D1_TP = 'CO' OR D1_TP = 'GV' OR D1_TP = 'LU') "
cQuery += "AND " + RetSqlName("SB1") + ".B1_FILIAL = D1_FILIAL "
cQuery += "AND " + RetSqlName("SB1") + ".B1_COD = D1_COD  "
cQuery += "AND " + RetSqlName("SB1") + ".D_E_L_E_T_ <> '*' "   
cQuery += "AND B1_CODSIMP <> '' AND B1_SITUACA = '1'  "
cQuery += "AND LTRIM(RTRIM(D1_CF)) NOT IN('1949','1664','2664','1415') "
cQuery += "GROUP BY D1_FILIAL,D1_DOC, D1_SERIE,D1_DTDIGIT,D1_FORNECE,D1_LOJA,D1_CF,D1_TIPO,B1_CODSIMP "
cQuery += "ORDER BY D1_FILIAL,D1_DOC, D1_SERIE,D1_DTDIGIT,B1_CODSIMP "


cQuery := ChangeQuery(cQuery)
If (Select("MSD1") != 0)
	dbSelectArea("MSD1")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MSD1"
TCSetField("MSD1","D1_DTDIGIT","D",08,0)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ1ÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Registros Entradas Por Produção
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*cQuery := ""
cQuery += "SELECT C2_FILIAL, C2_NUM,B1_CODSIMP,C2_PRODUTO,C2_EMISSAO,SUM(C2_QUANT * B1_VOLSIMP) AS QUANT "
cQuery += "FROM "+RetSqlName("SC2")+"  AS SC2," +RetSqlName("SB1")+" AS SB1 "
cQuery += "WHERE C2_FILIAL = '"+xFilial("SC2")+"' "                            
cQuery += "AND C2_PRIOR = '500' "
cQuery += "AND C2_EMISSAO >= '"+dtos(mv_par01)+"' AND C2_EMISSAO <= '"+dtos(mv_par02)+"' "
cQuery += "AND SB1.B1_FILIAL = SC2.C2_FILIAL "
cQuery += "AND SB1.B1_COD = SC2.C2_PRODUTO "
cQuery += "AND SB1.D_E_L_E_T_ <> '*' "
cQuery += "AND SC2.D_E_L_E_T_ <> '*'"
cQuery += "GROUP BY C2_FILIAL, C2_NUM,B1_CODSIMP,C2_PRODUTO,C2_EMISSAO "
cQuery += "ORDER BY C2_FILIAL, C2_NUM,B1_CODSIMP,C2_PRODUTO,C2_EMISSAO "*/



cQuery := ""                          

cQuery += "SELECT D3_FILIAL,D3_DOC,B1_CODSIMP,D3_COD,D3_EMISSAO,SUM(D3_QUANT * B1_VOLSIMP) AS QUANT "
cQuery += "FROM "+RetSqlName("SD3")+"  AS SD3," +RetSqlName("SB1")+" AS SB1 "
cQuery += "WHERE D3_FILIAL = '"+xFilial("SD3")+"' "                            
cQuery += "AND D3_TM IN('010', '002') "
cQuery += "AND D3_CF = 'PR0' "
If SM0->M0_CODIGO == "02" .and. SM0->M0_CODFIL == "05"               
	cQuery += "AND D3_COD IN('00024', '00005', '00086','00097','00034','00032') "
Else
	cQuery += "AND D3_COD IN('00024', '00005', '00086','00097','00034') "	
EndIf

cQuery += "AND D3_EMISSAO >= '"+dtos(mv_par01)+"' AND D3_EMISSAO <= '"+dtos(mv_par02)+"' "
cQuery += "AND SB1.B1_FILIAL = SD3.D3_FILIAL "
cQuery += "AND SB1.B1_COD = SD3.D3_COD "
cQuery += "AND SB1.D_E_L_E_T_ <> '*' "
cQuery += "AND SD3.D_E_L_E_T_ <> '*' "
cQuery += "GROUP BY D3_FILIAL, D3_DOC,B1_CODSIMP,D3_COD,D3_EMISSAO "
cQuery += "ORDER BY D3_FILIAL, D3_DOC,B1_CODSIMP,D3_COD,D3_EMISSAO "       



cQuery := ChangeQuery(cQuery)
If (Select("MSD3E") != 0)
	dbSelectArea("MSD3E")
	dbCloseArea()
Endif                 



TCQuery cQuery NEW ALIAS "MSD3E"
TCSetField("MSD3E","D3_EMISSAO","D",08,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ1ÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Registros Saídas Para Produção
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



cQuery := ""
cQuery += "SELECT D3_FILIAL, D3_DOC,B1_CODSIMP,D3_COD,D3_EMISSAO,SUM(D3_QUANT * B1_VOLSIMP) AS QUANT "
cQuery += "FROM "+RetSqlName("SD3")+"  AS SD3," +RetSqlName("SB1")+" AS SB1 "
cQuery += "WHERE D3_FILIAL = '"+xFilial("SD3")+"' "                            
cQuery += "AND D3_TM = '999' "
cQuery += "AND D3_CF = 'RE1' "
cQuery += "AND D3_COD IN('00013', '00004','00014','13040029', '00008' , '00103', '00086', '00810002') "
cQuery += "AND D3_EMISSAO >= '"+dtos(mv_par01)+"' AND D3_EMISSAO <= '"+dtos(mv_par02)+"' "
cQuery += "AND SB1.B1_FILIAL = SD3.D3_FILIAL "
cQuery += "AND SB1.B1_COD = SD3.D3_COD "
cQuery += "AND SB1.D_E_L_E_T_ <> '*' "
cQuery += "AND SD3.D_E_L_E_T_ <> '*'"
cQuery += "GROUP BY D3_FILIAL, D3_DOC,B1_CODSIMP,D3_COD,D3_EMISSAO "
cQuery += "ORDER BY D3_FILIAL, D3_DOC,B1_CODSIMP,D3_COD,D3_EMISSAO "       




cQuery := ChangeQuery(cQuery)
If (Select("MSD3S") != 0)
	dbSelectArea("MSD3S")
	dbCloseArea()
Endif


TCQuery cQuery NEW ALIAS "MSD3S"
TCSetField("MSD3S","D3_EMISSAO","D",08,0)
           


//************************************************************
		   
cMMAAAA    := Substr(Dtos(MV_PAR01),5,2)+Substr(Dtos(MV_PAR01),1,4)
cDDMMAAAAi := Substr(Dtos(MV_PAR01),7,2)+Substr(Dtos(MV_PAR01),5,2)+Substr(Dtos(MV_PAR01),1,4)
cDDMMAAAAf := Substr(Dtos(MV_PAR02),7,2)+Substr(Dtos(MV_PAR02),5,2)+Substr(Dtos(MV_PAR02),1,4)

cDiretorio := 'C:\SIMP\'
cArq       := cDiretorio + cDDMMAAAAi +'-'+ cDDMMAAAAf  + '.TXT'
MakeDir(cDiretorio)

if file(cArq)
   ferase(cArq)
endif

//
// Criacao do arquivo texto informado.                          
//
nHdlArq := MSFcreate(cArq)                     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecao de Chaves para os arquivos                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(DbSetOrder(1))               // filial+cod+loja
SB9->(DbSetOrder(2))               // filial+data

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracoes de arrays                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
aadd(aStru,{'SEQ'    ,'N',10,0})
aadd(aStru,{'LIN'    ,'C',242,0}) // ANTES 198
cArq := CriaTrab(aStru,.t.)
use &cArq alias AGR159 new
Index on SEQ to AGR15911

aStru := {}
aadd(aStru,{'PROOPE' ,'C',09,0})
aadd(aStru,{'QTDEI'  ,'N',14,3}) // Estoque Inicial
aadd(aStru,{'QTDKGI' ,'N',14,3})
aadd(aStru,{'QTDEF'  ,'N',14,3}) // Estoque Final
aadd(aStru,{'QTDKGF' ,'N',14,3})
aadd(aStru,{'QTDES'  ,'N',14,3}) // Total Saidas
aadd(aStru,{'QTDKGS' ,'N',14,3})
aadd(aStru,{'QTDEE'  ,'N',14,3}) // Total Entradas
aadd(aStru,{'QTDKGE' ,'N',14,3})
aadd(aStru,{'QTDETE' ,'N',14,3}) // Total Transferencia Entradas Producao
aadd(aStru,{'QTDKGTE','N',14,3})
aadd(aStru,{'QTDETS' ,'N',14,3}) // Total Transferencia Saidas Producao
aadd(aStru,{'QTDKGTS','N',14,3})
                              
aadd(aStru,{'QTDETEF' ,'N',14,3}) // Total Transferencia Entrada Entre Filiais
aadd(aStru,{'QTDKGTEF','N',14,3})
aadd(aStru,{'QTDETSF' ,'N',14,3}) // Total Transferencia Saidas Entre Filial 
aadd(aStru,{'QTDKGTSF','N',14,3})
cArq := CriaTrab(aStru,.t.)
use &cArq alias ESTOQUE new
Index on PROOPE to ESTOQUE2

cConta := 0

//****************************
//* Extrai Estoque Inicial
//****************************        

DbSelectArea("SB9")
dbSetOrder(2)
DbGotop()
Procregua(Reccount())
DbSeek(xFilial("SB9")+DTOS(MV_PAR03))
While !Eof() .And. xFilial("SB9") == SB9->B9_FILIAL .And. DTOS(SB9->B9_DATA) == DTOS(MV_PAR03)
   
   Incproc()

   cProOpe:= '000000000'
   cQtdKg := 0     
   
   cQuery := ""
	cQuery += "SELECT * "
	cQuery += "FROM "+RetSqlName("SB1")+" (NOLOCK) "
	cQuery += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += "AND D_E_L_E_T_ = '' AND B1_CODSIMP <> '' AND B1_SITUACA = '1' "
	cQuery += "AND B1_COD = '" + Alltrim(SB9->B9_COD) + "'"

	cQuery := ChangeQuery(cQuery)
	If (Select("MSB1S") != 0)
		dbSelectArea("MSB1S")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "MSB1S"   

	dbSelectArea("MSB1S")
	dbGoTop()
	
	if alltrim(MSB1S->B1_CODSIMP) == ""
   	  Sele SB9 
 	     DbSkip()
   	  Loop
   Endif                                    
   
   cProOpe := alltrim(MSB1S->B1_CODSIMP)
     
   cQtdKg  := int(SB9->B9_QINI) * MSB1S->B1_VOLSIMP
   cQINI   := int(SB9->B9_QINI) * MSB1S->B1_VOLSIMP

   SELE ESTOQUE
   If !DbSeek(cProOpe)
	      Reclock("ESTOQUE",.T.)
	      ESTOQUE->PROOPE := cProOpe
	      ESTOQUE->QTDEI  := int(cQINI)                                                         
	      ESTOQUE->QTDKGI := cQtdKg
	      MsUnlock("ESTOQUE") 
   Else
      Reclock("ESTOQUE",.F.)
      ESTOQUE->QTDEI  := ESTOQUE->QTDEI  + int(cQINI)
      ESTOQUE->QTDKGI := ESTOQUE->QTDKGI + int(cQtdKg)
      MsUnlock("ESTOQUE") 
   Endif
   
 	Sele SB9 
   DbSkip()

End

Sele ESTOQUE
DbGotop()
Procregua(Reccount())
While !Eof() 
   
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'
  
   cLinha := cAgeRegInf          // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA     // Mes Referencia
   
   cOperac := '3010003' // Operacao para estoque inicial
   
   cLinha := cLinha + cOperac   // Operacao    
   
//   if SM0->M0_CODFIL =  "01"
      cLinha := cLinha + cCodInst // Cod Instalacao 1
//   endif
//   if SM0->M0_CODFIL =  "02"
//      cLinha := cLinha + '1152416'  // Cod Instalacao 1
//   endif                        
//   if SM0->M0_CODFIL =  "03"
//      cLinha := cLinha + '0158429' // Cod Instalacao 1
//   endif

   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := ESTOQUE->QTDKGI

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDEI)
   cLinha  := cLinha + StrZero(cQtdPro,15)
   
   cLinha := cLinha + StrZero(cQtdPro,15) // Qtde do produto Quilogramas (Quilos + Miligramas) */
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

   cLinha := cLinha + cMun_ANP // Codigo Municipio
   cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
   cLinha := cLinha + '0000' // Cod do país
   cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
   cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
   cDoc   := '0000000'    
   cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
   cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
   cLinha := cLinha + cDtEmi // Data da operacao Comercial
   cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
   cProRes := '000000000' // Codigo do Produto/Operacao Resultante
   cRecGLP := '00'    // Recipiente de GLP
	
   cLinhax := ''
   cChaveNfe := "00000000000000000000000000000000000000000000"
   If !Empty(cFisQui1) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif

   Sele ESTOQUE
   DbSkip()

End                                          


//*****************************
//* Extrai Estoque Final
//*****************************            

DbSelectArea("SB9")
dbSetOrder(2)
DbGotop()
Procregua(Reccount())
DbSeek(xFilial("SB9")+DTOS(MV_PAR02))
While !Eof() .And. xFilial("SB9") == SB9->B9_FILIAL .And. DTOS(SB9->B9_DATA) == DTOS(MV_PAR02)
   
   Incproc()
   cQtdKg := 0              
   cProOpe := '000000000'       
   cQINI := 0   
   
   cQuery := ""
	cQuery += "SELECT * "
	cQuery += "FROM "+RetSqlName("SB1")+" (NOLOCK) "
	cQuery += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += "AND D_E_L_E_T_ = '' AND B1_CODSIMP <> '' AND B1_SITUACA = '1' "
	cQuery += "AND B1_COD = '" + Alltrim(SB9->B9_COD) + "'"

	cQuery := ChangeQuery(cQuery)
	If (Select("MSB1S") != 0)
		dbSelectArea("MSB1S")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "MSB1S"   

	dbSelectArea("MSB1S")
	dbGoTop()	
	if alltrim(MSB1S->B1_CODSIMP) == ""
   	  Sele SB9 
 	     DbSkip()
   	  Loop
   Endif                                    

   cProOpe := ALLTRIM(MSB1S->B1_CODSIMP)
  	cQtdKg  := int(SB9->B9_QINI) * MSB1S->B1_VOLSIMP
   cQINI   := int(SB9->B9_QINI) * MSB1S->B1_VOLSIMP
                           
   
   SELE ESTOQUE
   If !DbSeek(cProOpe)
      Reclock("ESTOQUE",.T.)
      ESTOQUE->PROOPE := cProOpe
      ESTOQUE->QTDEF  := int(cQINI)
      ESTOQUE->QTDKGF := cQtdKg
      MsUnlock("ESTOQUE") 
   Else   
      Reclock("ESTOQUE",.F.)
      ESTOQUE->QTDEF  := ESTOQUE->QTDEF  + int(cQINI)
      ESTOQUE->QTDKGF := ESTOQUE->QTDKGF + cQtdKg
      MsUnlock("ESTOQUE") 
   Endif
   
   Sele SB9 
   DbSkip()

End
 

Sele ESTOQUE
DbGotop()
Procregua(Reccount())
While !Eof() 
   
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := cAgeRegInf          // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '3020003' // Operacao para estoque final
   
   cLinha := cLinha + cOperac   // Operacao
   
//   if SM0->M0_CODFIL =  "01"
      cLinha := cLinha + cCodInst // Cod Instalacao 1
//   endif
//   if SM0->M0_CODFIL =  "02"
//      cLinha := cLinha + '1152416'  // Cod Instalacao 1
//   endif                        
//   if SM0->M0_CODFIL =  "03"
//      cLinha := cLinha + '0158429' // Cod Instalacao 1
//   endif
   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2
  
   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := ESTOQUE->QTDKGF   
   
   
   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDEF)
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000   
    

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif

   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

   cLinha := cLinha + cMun_ANP // Codigo Municipio
   cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
   cLinha := cLinha + '0000' // Cod do país
   cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
   cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
   cDoc   := '0000000'    
   cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
   cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
   cLinha := cLinha + cDtEmi // Data da operacao Comercial
   cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
   cProRes := '000000000' // Codigo do Produto/Operacao Resultante
   cRecGLP := '00'    // Recipiente de GLP
   cChaveNfe := "00000000000000000000000000000000000000000000"
	
   cLinhax := ''
   If !Empty(cFisQui1) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif

   Sele ESTOQUE
   DbSkip()

End


//*************************
//* Extrai NFs de Saida
//*************************        

sele MSD2
dbgotop()
Procregua(Reccount())
While !eof()                   

   //BUSCO CHAVE DOCUMENTO QUANDO FOR TIPO DOCUMENTO SPED   
	cQuery := ""                                                                                                   
	cQuery += "SELECT F2_CHVNFE  "
	cQuery += "FROM "+RetSqlName("SF2") + " (NOLOCK) " 
	cQuery += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*'  "
	cQuery += "AND F2_DOC     = '" + MSD2->D2_DOC     + "' "
	cQuery += "AND F2_SERIE   = '" + MSD2->D2_SERIE   + "' "
	cQuery += "AND F2_CLIENTE = '" + MSD2->D2_CLIENTE + "' "
	cQuery += "AND F2_LOJA    = '" + MSD2->D2_LOJA    + "' "

	cQuery := ChangeQuery(cQuery)
	If (Select("MSF2") != 0)
		dbSelectArea("MSF2")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "MSF2"   
	
	cChaveNfe := ""
	dbSelectArea("MSF2")
	dbGoTop()
	While !eof()   
	   cChaveNfe := MSF2->F2_CHVNFE 
	   MSF2->(dbskip())	
	EndDo                          
	
   //****************************************************
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

   cLinha := cAgeRegInf           // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   //Revisar             
   
   cInstANP := '0000000' 
   cOperac:= '1012002'
   DbSelectArea("SA1")
   DbGotop()
   DbSeek(xFilial("SA1")+MSD2->D2_CLIENTE+MSD2->D2_LOJA)
   

   If SA1->A1_PESSOA == 'J' .or. SA1->A1_PESSOA == 'F'
        cIdent := SA1->A1_CGC
   Endif
   If SA1->A1_PESSOA == 'F'
        cIdent := StrZero(val(Alltrim(SA1->A1_CGC)),14)
   Endif
   
   If !Empty(SA1->A1_Mun_ANP)
      cMun_ANP := SA1->A1_Mun_ANP
      IF Len(Alltrim(SA1->A1_Mun_ANP)) < 7
         cMun_ANP := StrZero(val(Alltrim(SA1->A1_Mun_ANP)),7)
      Endif
   Endif
   
   
   If !Empty(SA1->A1_ATIVIDA)
      cAtivida := SA1->A1_ATIVIDA
      IF Len(Alltrim(SA1->A1_ATIVIDA)) < 5
         cAtivida := StrZero(val(Alltrim(SA1->A1_ATIVIDA)),5)
      Endif
   Endif
  
   
   If !Empty(SA1->A1_INSTANP) .AND. ALLTRIM(SA1->A1_INSTANP) <> "0000000"
      cInstANP := SA1->A1_INSTANP
     	cOperac := '1012001'                                              
	   cIdent := '00000000000000'
      cMun_ANP := '0000000'
      cAtivida := '00000'  
      IF Len(Alltrim(SA1->A1_INSTANP)) < 7
         cInstANP := StrZero(val(Alltrim(SA1->A1_INSTANP)),7)
      Endif
   Endif                   
   
   If ALLTRIM(MSD2->D2_CF) == '5659' .OR. ALLTRIM(MSD2->D2_CF) == '6659' 
     	cOperac := '1052001'                                                 
   EndIf
   
   
   
   If cOperac == '0000000'
      Sele MSD2
      DbSkip()
      Loop
   Endif
 
   cLinha := cLinha + cOperac   // Operacao
   

   cLinha := cLinha + cCodInst // codigo instalacao 1

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   Sele MSD2
//******

/*   xCod     := MSD2->D2_COD 
   xEmissao := MSD2->D2_EMISSAO 

   *
   * Esta parte para buscar Certificado cfe Fabi 02/01/2007
   *
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SZ0")+" (NOLOCK) "
	cQuery += "WHERE Z0_FILIAL = '"+xFilial("SZ0")+"' "
	cQuery += "AND D_E_L_E_T_ = '' "
	cQuery += "AND Z0_COD = '"+xCod+"' "
	cQuery += "AND Z0_DTINI <= '"+Dtos(xEmissao)+"' "
	cQuery += "AND Z0_DTFIM >= '"+Dtos(xEmissao)+"' "

	If (Select("MSZ0") <> 0)
		dbSelectArea("MSZ0")
		dbCloseArea()
	Endif
	
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "MSZ0"

	xCertifi := Space(1)
	DbSelectArea("MSZ0")
	DbGoTop()
	While !Eof()  
		xCertifi := MSZ0->Z0_CERTIFI
		DbSelectArea("MSZ0")
	   DbSkip()
	EndDo
	cCertifi := Space(1)
	If !Empty(xCERTIFI) 
		cCertifi := Replicate('0',10-Len(Alltrim(xCertifi))) + Alltrim(xCertifi)
	Else
	   cCertifi := Replicate('0',10)
	EndIf*/

	cCertifi := Space(1)
   cCertifi := Replicate('0',10)
   
   Sele MSD2

   cProOpe:= '000000000'
   cQtdKg := 0
//*******************************************************************************

   cProOpe := alltrim(MSD2->B1_CODSIMP)
   cQtdKg  := int(MSD2->QUANT)

   SELE ESTOQUE  // Extrai Total Saidas           
   If !DbSeek(cProOpe)
      Reclock("ESTOQUE",.T.)    
      ESTOQUE->PROOPE := cProOpe   //RODRIGO
      If alltrim(MSD2->D2_CF) == '5659' .OR. alltrim(MSD2->D2_CF) == '6659'  //.AND. 1 = 2 //TRANSFERENCIA ENTRE FILIAIS
	      ESTOQUE->QTDETSF  := int(MSD2->QUANT)
   	   ESTOQUE->QTDKGTSF := cQtdKg                 	      	                                             
      Else
	      ESTOQUE->QTDES  := int(MSD2->QUANT)
   	   ESTOQUE->QTDKGS := cQtdKg      
      EndIf
      MsUnlock("ESTOQUE") 
   Else
      Reclock("ESTOQUE",.F.)
      If alltrim(MSD2->D2_CF) == '5659' .OR. alltrim(MSD2->D2_CF) == '6659' //.AND. 1=2
	      ESTOQUE->QTDETSF  := ESTOQUE->QTDETSF  + int(MSD2->QUANT)
   	   ESTOQUE->QTDKGTSF := ESTOQUE->QTDKGTSF + int(MSD2->QUANT)
      Else
  	      ESTOQUE->QTDES  := ESTOQUE->QTDES  + int(MSD2->QUANT)
   	   ESTOQUE->QTDKGS := ESTOQUE->QTDKGS + int(MSD2->QUANT)
      EndIf
      MsUnlock("ESTOQUE") 
   Endif

   SELE MSD2
   
   cLinha := cLinha + cProOpe // Cod Prod Operado
   
	cQtdPro := Int(MSD2->QUANT)
   cLinha  := cLinha + StrZero(cQtdPro,15)        

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   
   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
    
   cLinha := cLinha + cMun_ANP // Codigo Municipio
   cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
   cLinha := cLinha + '0000' // Cod do país
   cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
   cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
   Sele MSD2          
   cDoc   := MSD2->D2_DOC
   IF Len(Alltrim(MSD2->D2_DOC)) < 7
      cDoc := StrZero(val(Alltrim(MSD2->D2_DOC)),7)
   Endif  
   
   //Se a nf tiver chave eletronica zera DOC e Série
   If trim(cChaveNfe) == "" //.or. (cOperac == "1011001" .OR. cOperac == "1011004" .OR. cOperac == "1011005" .OR. cOperac == "1012001" .OR. ;
    //  cOperac == "1012002" )
	   cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
   	   cLinha := cLinha + StrZero(val(Alltrim(MSD2->D2_SERIE)),2)  // Cod Serie da NF da operacao comercial 04 = Unica    
   Else 
  	   cLinha := cLinha + '0000000' // Nr da NF da operacao Comercial
   	   cLinha := cLinha + '00'  // Cod Serie da NF da operacao comercial 04 = Unica                                                                                                                        
   EndIf
	
   cDtEmi := strzero(day(MSD2->D2_EMISSAO),2)+strzero(month(MSD2->D2_EMISSAO),2)+strzero(year(MSD2->D2_EMISSAO),4)	//AQUI EMISSAO
   cLinha := cLinha + cDtEmi // Data da operacao Comercial
   cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '   '
   cMetodo1 := '   '
   cUnMedi1 := '  '
   cVlCara1 := '          '
   cMassaE1 := '       '
   cFisQui11:= '   '
   cMetodo11:= '   '
   cUnMedi11:= '  '
   cVlCara11:= '          '
   cMassaE11:= '       '
   cFisQui2 := '   '
   cMetodo2 := '   '
   cUnMedi2 := '  '
   cVlCara2 := '          '
   cMassaE2 := '       '
   cFisQui21:= '   '
   cMetodo21:= '   '
   cUnMedi21:= '  '
   cVlCara21:= '          '
   cMassaE21:= '       '
   cFisQui3 := '   '
   cMetodo3 := '   '
   cUnMedi3 := '  '
   cVlCara3 := '          '
   cMassaE3 := '       '
   cFisQui4 := '   '
   cMetodo4 := '   '
   cUnMedi4 := '  '
   cVlCara4 := '          '
   cMassaE4 := '       '
   cFisQui5 := '   '
   cMetodo5 := '   '
   cUnMedi5 := '  '
   cVlCara5 := '          '                                                                  
   cMassaE5 := '       '
   
   *
   * Cfe Fabi 02/01/2007 somente sera considerar uma linha de caracteristica cfe abaixo
   *
   cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	cVlCara1 := cCertifi // Valor Encontrado da Caracteristica
	/*If SD2->D2_UM == 'KG' // Caso Seja unidade medida KG cfe Fabi/Batista considera massa igual a qtde vendida 02/01/2007
      cMassaE1 := StrZero(int(MSD2->D2_QUANT),7)  // Massa Especifica do Produto
 	Else
      cMassaE1 := '0000000'    // Massa Especifica do Produto
   Endif                                                     */
   cMassaE1 := '0000000'    // Massa Especifica do Produto  (Por enquanto vamos trabalhar somente com litros)
   cProRes := '000000000' //cProOpe // Codigo do Produto/Operacao Resultante
   cRecGLP := '00'    // Recipiente de GLP
   If trim(cChaveNfe)==""
      cChaveNfe := "00000000000000000000000000000000000000000000"
   EndIf
//	cLinha  := cLinha + cChaveNfe

   cLinhax := ''
   If !Empty(cFisQui1) 
     cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe

	  SELE AGR159
     Reclock("AGR159",.T.)
     AGR159->SEQ    := cConta
     AGR159->LIN    := cLinhax
     MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui11) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui11 + cMetodo11 + cUnMedi11 + cVlCara11 + cProRes + cMassaE11 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui2) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui2 + cMetodo2 + cUnMedi2 + cVlCara2 + cProRes + cMassaE2 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui21) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui21 + cMetodo21 + cUnMedi21 + cVlCara21 + cProRes + cMassaE21 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui3) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui3 + cMetodo3 + cUnMedi3 + cVlCara3 + cProRes + cMassaE3 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui4) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui4 + cMetodo4 + cUnMedi4 + cVlCara4 + cProRes + cMassaE4 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui5) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui5 + cMetodo5 + cUnMedi5 + cVlCara5 + cProRes + cMassaE5 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
//AQUIII   



// *
//   * Extrai Saida por Transferencia para outro produto
//   *   foi tirado do arquivo!!    

  

   sele MSD2
   dbskip()
END                             





*
* Extrai Producao
*    
If SM0->M0_CODIGO == '02'
sele MSD3E
dbgotop()
Procregua(Reccount())
While !eof() 
   Incproc()
   
   *
   * Entrada Produção
   *                       

	  cLinha := ''
	  cOperac:= '0000000'

	  cLinha := cAgeRegInf                   // Nr Agente Reg Informante

	  cLinha := cLinha + cMMAAAA              // Mes Referencia

     cOperac := '1021004' // Saidas por Transferencia para outro produto
	   
	  cLinha := cLinha + cOperac   // Operacao
	   
//     if SM0->M0_CODFIL =  "01"
        cLinha := cLinha + cCodInst // Cod Instalacao 1
//     endif
//     if SM0->M0_CODFIL =  "02"
//        cLinha := cLinha + '1152416'  // Cod Instalacao 1
//     endif                        
//     if SM0->M0_CODFIL =  "03"
//        cLinha := cLinha + '0158429' // Cod Instalacao 1
//     endif

	   
	  cInstANP := '0000000'
	  cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	  cProOpe:= alltrim(MSD3E->B1_CODSIMP) //'000000000'
	  cQtdKg := 0

 
	  If cProOpe == '000000000' .OR. ALLTRIM(cProOpe) == ""
	     Sele MSD3E
	     DbSkip()
	     Loop
	  Endif      

		//revisar	   
		/*	  If (Alltrim(MSC2->C2_PRODUTO) == '00029'  .And. Alltrim(SG1->G1_COMP) == '00027') .or.; // Caso Diesel com Aditivo ajusta Qtde da saida do Aditivo
		  ((Alltrim(MSC2->C2_PRODUTO) == '00096' .or. Alltrim(MSC2->C2_PRODUTO) == '00097')  .And. Alltrim(SG1->G1_COMP) == '00810002') .or.;
		  ((Alltrim(MSC2->C2_PRODUTO) == '00078' .or. Alltrim(MSC2->C2_PRODUTO) == '00087')  .And. Alltrim(SG1->G1_COMP) == '00810002')
           cQtdPro := MSC2->C2_QUANT - cQtdPro     // Calcula valor correspondente ao Aditivo do Diesel
	  ElseIf Alltrim(MSC2->C2_PRODUTO) == '88888' .And. ; // Caso Diesel B2 Aditivado
         (Alltrim(SG1->G1_COMP) == '00027')
         cQtdPro := MSC2->C2_QUANT - cQtdPro 
	  Else
   	     cQtdPro := Int(MSC2->C2_QUANT * SG1->G1_QUANT)         
	     If cQtdPro == 0
		    cQtdPro := Int(MSC2->C2_QUANT * SG1->G1_QUANT * 1000)
		 Endif
	  Endif      */
	  
     cQtdPro := Int(MSD3E->QUANT) 

	  SELE ESTOQUE  // Extrai Total Transferencia Entradas
	  If !DbSeek(cProOpe)
	     Reclock("ESTOQUE",.T.)
	     ESTOQUE->PROOPE  := cProOpe
	     ESTOQUE->QTDETE  := int(MSD3E->QUANT)
	     ESTOQUE->QTDKGTE := cQtdKg
	     MsUnlock("ESTOQUE") 
	  Else
	     Reclock("ESTOQUE",.F.)
	     ESTOQUE->QTDETE  := ESTOQUE->QTDETE  + int(MSD3E->QUANT)
	     ESTOQUE->QTDKGTE := ESTOQUE->QTDKGTE + cQtdKg
	     MsUnlock("ESTOQUE") 
	  Endif
	

	  cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	  cLinha  := cLinha + StrZero(cQtdPro,15)       // Qtde produto operado na unidade de medida oficial ANP
	
	  cQtdKgl := int(cQtdKg)
	  cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

      If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
         cQtdKgm := 1
      Endif
	  If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	     cQtdKgm := 1
	  Endif    
	  

	   
	  cLinha := cLinha +  StrZero(cQtdPro,15)  // Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	  cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 0 = Interno cfe FAbi
	  cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	  cIdent := '00000000000000'
	  cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	  cMun_ANP := '0008518'

	  cAtivida := '51519'  

	  cLinha := cLinha + '0000000' // Codigo Municipio
	  cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
	  cLinha := cLinha + '0000' // Cod do país
	  cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	  cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
	  cDoc   := '0000000' // Numero da NF fica zeros por ser transacao interna cfe Fabi
	  cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	  cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 00 == Interna
		
	  cDtEmi := strzero(day(MSD3E->D3_EMISSAO),2)+strzero(month(MSD3E->D3_EMISSAO),2)+strzero(year(MSD3E->D3_EMISSAO),4)	
	  cLinha := cLinha + cDtEmi // Data da operacao Comercial
	  cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
     cFisQui1 := '000' // Cfe Fabi Ordens de produçao sera tudo Zero!! 02/01/2007
	  cMetodo1 := '000'
	  cUnMedi1 := '00'
	  cVlCara1 := '0000000000'
	  cMassaE1 := '0000000'
	  cRecGLP := '00'    // Recipiente de GLP
     cChaveNfe := "00000000000000000000000000000000000000000000"

	  cLinhax := ''
	  If !Empty(cFisQui1) 
	     cConta := cConta + 1  // Nr Registro
		  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe
	
	 	  SELE AGR159
	     Reclock("AGR159",.T.)
	     AGR159->SEQ    := cConta
	     AGR159->LIN    := cLinhax
	     MsUnlock("AGR159") 
	  Endif      
	  Sele MSD3E
     DBSKIP()
EndDo

//     cComp := 'S' ///ERA SIM

   *
   * SAIDAS PARA PRODUÇÃO
   *                                                        
  

sele MSD3S
dbgotop()
  Procregua(Reccount())
  While !eof()                                                        
       
		cQuery := ""
		cQuery += "SELECT D3_DOC, D3_COD "
		cQuery += "FROM "+RetSqlName("SD3")+"  AS SD3 "
		cQuery += "WHERE D3_FILIAL = '"+xFilial("SD3")+"' "                            
		cQuery += "AND D3_DOC = '" + MSD3S->D3_DOC + "' " 
		cQuery += "AND D_E_L_E_T_ <> '*' 
		
		
		cQuery := ChangeQuery(cQuery)
		If (Select("MSD3SV") != 0)
			dbSelectArea("MSD3SV")
			dbCloseArea()
		Endif
		TCQuery cQuery NEW ALIAS "MSD3SV"
		
		                 

		
		
		
		cConsidera := "S"
		sele MSD3SV
		dbGoTop() 
		while !eof()   
		    If MSD3SV->D3_COD == '00032'  
		       cConsidera := "N"                                              

  	       EndIf                        
		    If MSD3SV->D3_COD == '00076'
		       cConsidera := "N"		    
		    endif              //1022015
		   SELE MSD3SV
		   dbskip()
		EndDo  
		
		IF ALLTRIM(MSD3S->D3_COD) == "00004"
			ALERT("ANTES CONSIDERA")
		EndIf		
                 
  
       If cConsidera == "N
           SELE MSD3S 
           dbskip()
           loop
        EndIf
  
  
		IF ALLTRIM(MSD3S->D3_COD) == "00004"
			alert(MSD3S->QUANT)
		EndIf
  
  
		  sele MSD3S
		  
	  	  cLinha := ''
		  cOperac:= '0000000'
	  	                                         
		  cLinha := cAgeRegInf           // Nr Agente Reg Informante
		  cLinha := cLinha + cMMAAAA              // Mes Referencia
	
		  cOperac := '1022015' // SAIDAS PARA PRODUCAO
	   
		  cLinha := cLinha + cOperac   // Operacao
	   	
//	     if SM0->M0_CODFIL =  "01"
   	     cLinha := cLinha + cCodInst    // Cod Instalacao 1
//	     endif
//   	  if SM0->M0_CODFIL =  "02"
//	        cLinha := cLinha + '1152416'  // Cod Instalacao 1
//   	  endif                        
//	     if SM0->M0_CODFIL =  "03"
//   	     cLinha := cLinha + '0158429' // Cod Instalacao 1
//	     endif	   

		  cInstANP := '0000000'
		  cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	      
		  cProOpe:= '000000000'
		  cQtdKg := 0
			//*************************************************************	  
	     cProOpe := ALLTRIM(MSD3S->B1_CODSIMP)                                
 		  cQtdKg  := MSD3S->QUANT           


		  cLinha := cLinha + cProOpe // Cod Prod Operado
	   
		  cQtdPro := Int(MSD3S->QUANT)
		  cLinha  := cLinha + StrZero(cQtdPro,15)
	
		  cQtdKgl := int(cQtdKg)
		                     
        if cQtdPro < 1
           cQtdPro := 1
           cQtdKgl := 1
        endif
		  
		  
		  cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000
	                                          
	   
		  cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
		  cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 0 = Interno cfe FAbi
		  cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
		  cIdent := '00000000000000'
		  cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
		  cMun_ANP := '0008518'
	
		  cAtivida := '51519'  
	
		  cLinha := cLinha + '0000000' // Codigo Municipio
		  cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
		  cLinha := cLinha + '0000' // Cod do país
		  cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	     cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
		  cDoc   := '0000000' // Numero da NF fica zeros por ser transacao interna cfe Fabi
		  cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
		  cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 00 == Interna
		
		  cDtEmi := strzero(day(MSD3S->D3_EMISSAO),2)+strzero(month(MSD3S->D3_EMISSAO),2)+strzero(year(MSD3S->D3_EMISSAO),4)	
		  cLinha := cLinha + cDtEmi // Data da operacao Comercial
		  cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
		  cFisQui1 := '000' // Cfe Fabi transferencia sera tudo Zero!! 02/01/2007
		  cMetodo1 := '000'
		  cUnMedi1 := '00'
		  cVlCara1 := '0000000000'
		  cMassaE1 := '0000000'
		  cRecGLP := '00'    // Recipiente de GLP
		
		  cLinhax := ''
        cChaveNfe := "00000000000000000000000000000000000000000000"	  
	  
		  SELE ESTOQUE  // Extrai Total Transferencia Entradas
		  If !DbSeek(cProOpe)
		     Reclock("ESTOQUE",.T.)
	     	  ESTOQUE->PROOPE  := cProOpe
	   	  ESTOQUE->QTDETS  := int(cQtdPro)
		     ESTOQUE->QTDKGTS := cQtdKg
		     MsUnlock("ESTOQUE") 
		  Else
		     Reclock("ESTOQUE",.F.)
	   	  ESTOQUE->QTDETS  := ESTOQUE->QTDETS  + int(cQtdPro)
	        ESTOQUE->QTDKGTS := ESTOQUE->QTDKGTS + cQtdKg
		     MsUnlock("ESTOQUE") 
		  Endif

		  If !Empty(cFisQui1) 
		     cConta := cConta + 1  // Nr Registro
			  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe
	
	 		  SELE AGR159
		     Reclock("AGR159",.T.)
		     AGR159->SEQ    := cConta
	   	  AGR159->LIN    := cLinhax
	     	  MsUnlock("AGR159") 
		  Endif
	     Sele MSD3S 
	     DBSKIP()
EndDo  

endif /////para teste 






*                       
* Extrai NFs de Entrada
*        
sele MSD1
dbgotop()
Procregua(Reccount())
While !eof()                          
    
   
   //BUSCO CHAVE DOCUMENTO QUANDO FOR TIPO DOCUMENTO SPED   
	cQuery := ""                                                                                                   
	cQuery += "SELECT F1_CHVNFE  "
	cQuery += "FROM "+RetSqlName("SF1") + " (NOLOCK) " 
	cQuery += "WHERE F1_FILIAL = '"+xFilial("SF1")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*'  "
	cQuery += "AND F1_DOC     = '" + MSD1->D1_DOC     + "' "
	cQuery += "AND F1_SERIE   = '" + MSD1->D1_SERIE   + "' "
	cQuery += "AND F1_FORNECE = '" + MSD1->D1_FORNECE + "' "
	cQuery += "AND F1_LOJA    = '" + MSD1->D1_LOJA    + "' "

	cQuery := ChangeQuery(cQuery)
	If (Select("MSF1") != 0)
		dbSelectArea("MSF1")
		dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "MSF1"   
	
	cChaveNfe := ""
	dbSelectArea("MSF1")
	dbGoTop()
	While !eof()   
	   cChaveNfe := MSF1->F1_CHVNFE
	   MSF1->(dbskip())	
	EndDo  
	// FIM CHAVE
   
   Incproc()
   cLinha := ''
   cOperac:= '0000000'

  
   cLinha := cAgeRegInf                   // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cInstANP := '0000000'  
   cOperac  := '1011002'   
   


   IF MSD1->D1_TIPO = "N"
	   DbSelectArea("SA2")
	   DbGotop()
	   DbSeek(xFilial("SA2")+MSD1->D1_FORNECE+MSD1->D1_LOJA)
     
   	If SA2->A2_TIPO == 'J' .or. SA2->A2_TIPO == 'F'
	      cIdent := SA2->A2_CGC
   	Endif
	   If SA2->A2_TIPO == 'F'
   	   cIdent := StrZero(val(Alltrim(SA2->A2_CGC)),14)
	   Endif
   
   	If !Empty(SA2->A2_Mun_ANP)
	      cMun_ANP := SA2->A2_Mun_ANP
      	IF Len(Alltrim(SA2->A2_Mun_ANP)) < 7
   	      cMun_ANP := StrZero(val(Alltrim(SA2->A2_Mun_ANP)),7)
      	Endif
	   Endif
 
   	If !Empty(SA2->A2_ATIVIDA)
      	cAtivida := SA2->A2_ATIVIDA
	      IF Len(Alltrim(SA2->A2_ATIVIDA)) < 5
   	      cAtivida := StrZero(val(Alltrim(SA2->A2_ATIVIDA)),5)
      	Endif
	   Endif                
	   
   	If (Alltrim(MSD1->D1_CF)  == '1662' .Or. Alltrim(MSD1->D1_CF) == '2662' .OR.;
       	 Alltrim(MSD1->D1_CF)  == '1661' .Or. Alltrim(MSD1->D1_CF) == '2661');
      	.AND. (Empty(ALLTRIM(SA2->A2_INSTANP)) .OR. ALLTRIM(SA2->A2_INSTANP) = "0000000")
	      cOperac := '1011005'
   	Endif
                                                                         
	   If !Empty(SA2->A2_INSTANP) .AND. ALLTRIM(SA2->A2_INSTANP) <> "0000000"
   	   cInstANP := SA2->A2_INSTANP
      	cOperac  := '1011001'      
	      cMun_ANP := '0000000'      
	      cAtivida := '00000'  
	      cIdent := '00000000000000'

   	   IF Len(Alltrim(SA2->A2_INSTANP)) < 7
      	   cInstANP := StrZero(val(Alltrim(SA2->A2_INSTANP)),7)
      	Endif
      	
 			If (Alltrim(MSD1->D1_CF)  == '1662' .Or. Alltrim(MSD1->D1_CF) == '2662' .OR.;
       		 Alltrim(MSD1->D1_CF)  == '1661' .Or. Alltrim(MSD1->D1_CF) == '2661');
	      	.AND. !Empty(ALLTRIM(SA2->A2_INSTANP))
		      cOperac := '1011004'
   		Endif

	   Endif
   
   ENDIF    
   
   
   
   
   IF MSD1->D1_TIPO = "D"
   	DbSelectArea("SA1")
	   DbGotop()
	   DbSeek(xFilial("SA1")+MSD1->D1_FORNECE+MSD1->D1_LOJA)
   	

   	If SA1->A1_PESSOA == 'J' .or. SA1->A1_PESSOA == 'F'
      	  cIdent := SA1->A1_CGC
	   Endif
   	If SA1->A1_PESSOA == 'F'
      	  cIdent := StrZero(val(Alltrim(SA1->A1_CGC)),14)
	   Endif 	
   
   	If !Empty(SA1->A1_Mun_ANP)
      	cMun_ANP := SA1->A1_Mun_ANP
	      IF Len(Alltrim(SA1->A1_Mun_ANP)) < 7
   	      cMun_ANP := StrZero(val(Alltrim(SA1->A1_Mun_ANP)),7)
      	Endif
	   Endif
   
   
   	If !Empty(SA1->A1_ATIVIDA)
      	cAtivida := SA1->A1_ATIVIDA
	      IF Len(Alltrim(SA1->A1_ATIVIDA)) < 5
   	      cAtivida := StrZero(val(Alltrim(SA1->A1_ATIVIDA)),5)
      	Endif
	   Endif


   	If Alltrim(MSD1->D1_CF) == '1662' .Or. Alltrim(MSD1->D1_CF) == '2662' .OR.;
      	Alltrim(MSD1->D1_CF) == '1661' .Or. Alltrim(MSD1->D1_CF) == '2661' 
	       cOperac := '1011005'
   	Endif
   
   
   	If !Empty(SA1->A1_INSTANP) .AND. ALLTRIM(SA1->A1_INSTANP) <> "0000000"
      	cInstANP := SA1->A1_INSTANP
			cOperac := '1012001'                
		   cIdent := '00000000000000'
      	cMun_ANP := '0000000'
	      cAtivida := '00000'                                                        
     	   If Alltrim(MSD1->D1_CF) == '1662' .Or. Alltrim(MSD1->D1_CF) == '2662' .OR.;
     	     Alltrim(MSD1->D1_CF) == '1661' .Or. Alltrim(MSD1->D1_CF) == '2661' 
         	cOperac := '1011004'
	      Endif 	
   	   IF Len(Alltrim(SA1->A1_INSTANP)) < 7
      	   cInstANP := StrZero(val(Alltrim(SA1->A1_INSTANP)),7)
	      Endif
   	Endif
                                                                                  
      If (Alltrim(MSD1->D1_CF) == '1662' .Or. Alltrim(MSD1->D1_CF) == '2662' .OR.;
      	 Alltrim(MSD1->D1_CF) == '1661' .Or. Alltrim(MSD1->D1_CF) == '2661' ) .AND. (Empty(SA1->A1_INSTANP) .OR. ALLTRIM(SA1->A1_INSTANP) = "0000000")
	       cOperac := '1011005'
   	Endif
   	
	ENDIF
	
   If Alltrim(MSD1->D1_CF) == '1659' //.Or. Alltrim(MSD1->D1_CF) == '2652'
   	   cOperac := '1051001'
   Endif
   


   If cOperac == '0000000'
      Sele MSD1 
      DbSkip()
      Loop
   Endif
   
   cLinha := cLinha + cOperac   // Operacao

   cLinha := cLinha + cCodInst // Cod Instalacao 1
   

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   Sele MSD1
      
   cProOpe:= '000000000'
   cQtdKg := 0               
   
//***********************************************************
/*   cQuery := ""
   cQuery += "SELECT * "
   cQuery += "FROM "+RetSqlName("SB1")+" (NOLOCK) "
 	cQuery += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
 	cQuery += "AND D_E_L_E_T_ = '' AND B1_CODSIMP <> '' AND B1_SITUACA = '1' "
 	cQuery += "AND B1_COD = '" + Alltrim(MSD1->D1_COD) + "'"

	cQuery := ChangeQuery(cQuery)
	If (Select("MSB1S") != 0)
	   dbSelectArea("MSB1S")
	   dbCloseArea()
	Endif
	TCQuery cQuery NEW ALIAS "MSB1S"   

	dbSelectArea("MSB1S")
	dbGoTop()
	
   if alltrim(MSB1S->B1_CODSIMP) == ""
      Sele MSD1
      DbSkip()
      Loop
   Endif 	  */

  /* cProOpe := alltrim(MSB1S->B1_CODSIMP)
   cQtdKg  := INT(MSD1->D1_QUANT) * MSB1S->B1_VOLSIMP*/
   cProOpe := alltrim(MSD1->B1_CODSIMP)       
   cQtdKg  := INT(MSD1->QUANT) 
      
//***********************************************************   
                                                        

   SELE ESTOQUE  // Extrai Total Entradas               
   If !DbSeek(cProOpe)
      Reclock("ESTOQUE",.T.)
      ESTOQUE->PROOPE := cProOpe           
      If alltrim(MSD1->D1_CF) == '1659' .OR. alltrim(MSD1->D1_CF) == '2659' //.AND. 1=2//TRANSFERENCIA ENTRE FILIAIS
		   ESTOQUE->QTDETEF  := INT(MSD1->QUANT) 
      	ESTOQUE->QTDKGTEF := cQtdKg   
      ELSE
		   ESTOQUE->QTDEE  :=  INT(MSD1->QUANT) 
      	ESTOQUE->QTDKGE := cQtdKg      	
      EndIf
      MsUnlock("ESTOQUE") 
   Else
      Reclock("ESTOQUE",.F.)                                               
      If alltrim(MSD1->D1_CF) == '1659' .OR. alltrim(MSD1->D1_CF) == '2659' //.AND. 1= 2
	      ESTOQUE->QTDETEF  := ESTOQUE->QTDETEF  +  INT(MSD1->QUANT) 
   	   ESTOQUE->QTDKGTEF := ESTOQUE->QTDKGTEF + cQtdKg
   	else
	      ESTOQUE->QTDEE  := ESTOQUE->QTDEE  +  INT(MSD1->QUANT) 
   	   ESTOQUE->QTDKGE := ESTOQUE->QTDKGE + cQtdKg   	   	
   	endif   
      MsUnlock("ESTOQUE") 
   Endif

   SELE MSD1

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
//   cQtdPro := Int(MSD1->D1_QUANT) * MSB1S->B1_VOLSIMP
   cQtdPro := INT(MSD1->QUANT) 
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   


   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cLinha := cLinha + cMun_ANP // Codigo Municipio
   cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
   cLinha := cLinha + '0000' // Cod do país
   cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
   cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
   Sele MSD1
   cDoc   := MSD1->D1_DOC
   IF Len(Alltrim(MSD1->D1_DOC)) < 7
      cDoc := StrZero(val(Alltrim(MSD1->D1_DOC)),7)
   Endif
   

   // Se Nf for tipo SPED zerar numero da nota/serie   
   If trim(cChaveNfe) == ""
      cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
      cLinha := cLinha + StrZero(val(Alltrim(MSD1->D1_SERIE)),2)  // Cod Serie da NF da operacao comercial 04 = Unica    
   Else
      cLinha := cLinha + '0000000' // Nr da NF da operacao Comercial
      cLinha := cLinha + '00'  // Cod Serie da NF da operacao comercial 04 = Unica       
   EndIf
	
   cDtEmi := strzero(day(MSD1->D1_DTDIGIT),2)+strzero(month(MSD1->D1_DTDIGIT),2)+strzero(year(MSD1->D1_DTDIGIT),4)	
   cLinha := cLinha + cDtEmi // Data da operacao Comercial
   cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '   '
   cMetodo1 := '   '
   cUnMedi1 := '  '
   cVlCara1 := '          '
   cMassaE1 := '       '
   cFisQui11:= '   '
   cMetodo11:= '   '
   cUnMedi11:= '  '
   cVlCara11:= '          '
   cMassaE11:= '       '
   cFisQui2 := '   '
   cMetodo2 := '   '
   cUnMedi2 := '  '
   cVlCara2 := '          '
   cMassaE2 := '       '
   cFisQui21:= '   '
   cMetodo21:= '   '
   cUnMedi21:= '  '
   cVlCara21:= '          '
   cMassaE21:= '       '
   cFisQui3 := '   '
   cMetodo3 := '   '
   cUnMedi3 := '  '
   cVlCara3 := '          '
   cMassaE3 := '       '
   cFisQui4 := '   '
   cMetodo4 := '   '
   cUnMedi4 := '  '
   cVlCara4 := '          '
   cMassaE4 := '       '
   cFisQui5 := '   '
   cMetodo5 := '   '
   cUnMedi5 := '  '
   cVlCara5 := '          '
   cMassaE5 := '       '
   
   *
   * Cfe Fabi entradas serao tudo zero!! 02/01/2007
   *
   cFisQui1 := '000' // Codigo da Caracteristica Fisico-Quimica do produto
	cMetodo1 := '000' // Codigo do Metodo Utilizado para Afericao da Caracteristica
	cUnMedi1 := '00'  // Codigo da Unidade de Medida da Caracteristica 
	cVlCara1 := '0000000000' // Valor Encontrado da Caracteristica
   cMassaE1 := '0000000'    // Massa Especifica do Produto
   cProRes := '000000000' //cProOpe // Codigo do Produto/Operacao Resultante
   cRecGLP := '00'    // Recipiente de GLP
   
   if trim(cChaveNfe) == ""
      cChaveNfe := "00000000000000000000000000000000000000000000"
   EndIf
	
   cLinhax := ''
   If !Empty(cFisQui1) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui11) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui11 + cMetodo11 + cUnMedi11 + cVlCara11 + cProRes + cMassaE11 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui2) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui2 + cMetodo2 + cUnMedi2 + cVlCara2 + cProRes + cMassaE2 + cRecGLP+ cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui21) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui21 + cMetodo21 + cUnMedi21 + cVlCara21 + cProRes + cMassaE21 + cRecGLP+ cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui3) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui3 + cMetodo3 + cUnMedi3 + cVlCara3 + cProRes + cMassaE3 + cRecGLP+ cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui4) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui4 + cMetodo4 + cUnMedi4 + cVlCara4 + cProRes + cMassaE4 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif
   cLinhax := ''
   If !Empty(cFisQui5) 
      cConta := cConta + 1  // Nr Registro
	  cLinhax:= StrZero(cConta,10) + cLinha + cFisQui5 + cMetodo5 + cUnMedi5 + cVlCara5 + cProRes + cMassaE5 + cRecGLP + cChaveNfe

	  SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
   Endif

   sele MSD1
   dbskip()

END                      


*
* Extrai Total Saidas e Entradas , Total Transferencia saidas e Transferencia Entradas 
* e Reg. Inventario caso diferencas (Inicial + (Entrada + Transf. Entradas) - (Saida + Transf. Saidas) = Final)
*
Sele ESTOQUE

DbGotop()
Procregua(Reccount())
While !Eof()                                                             
   *
   * Reg. Inventario caso diferencas (Inicial + (Entrada + Transf. Entradas) - (Saida + Transf. Saidas) = Final)
   *                
   cTotEnt   := ''
   nQTDEINS  := 0
   nQTDKGINS := 0
   nQTDEINE  := 0
   nQTDKGINE := 0
//   nQTDEIN   := (ESTOQUE->QTDEI + (ESTOQUE->QTDEE + ESTOQUE->QTDETE + ESTOQUE->QTDETEF )  - (ESTOQUE->QTDES + ESTOQUE->QTDETS+ QTDETSF)) - ESTOQUE->QTDEF
//   nQTDKGIN  := (ESTOQUE->QTDKGI + (ESTOQUE->QTDKGE + ESTOQUE->QTDKGTE + ESTOQUE->QTDETSF) - (ESTOQUE->QTDKGS + ESTOQUE->QTDKGTS + ESTOQUE->QTDKGTSF)) - ESTOQUE->QTDKGF

 nQTDEIN   := (ESTOQUE->QTDEI + (ESTOQUE->QTDEE + ESTOQUE->QTDETE )  - (ESTOQUE->QTDES + ESTOQUE->QTDETS)) - ESTOQUE->QTDEF                   
 nQTDKGIN  := (ESTOQUE->QTDKGI + (ESTOQUE->QTDKGE + ESTOQUE->QTDKGTE ) - (ESTOQUE->QTDKGS + ESTOQUE->QTDKGTS )) - ESTOQUE->QTDKGF
 
   
   If nQTDEIN < 0 // Antes de Extrair o registro de saida inventario Extrai Total Entradas
	   *
	   * Total Entradas
	   *
	   cTotEnt := 'S'
	   Incproc()
	   cLinha := Space(01)
	   cOperac:= '0000000'
	
	  
	   cLinha := cAgeRegInf                   // Nr Agente Reg Informante
	   cLinha := cLinha + cMMAAAA              // Mes Referencia
	   
	   cOperac := '1011998' // Operacao para Total Entradas Comerciais Nacionais
	   
	   cLinha := cLinha + cOperac   // Operacao
	   
//      if SM0->M0_CODFIL =  "01"
         cLinha := cLinha + cCodInst // Cod Instalacao 1
//      endif
//      if SM0->M0_CODFIL =  "02"
//         cLinha := cLinha + '1152416'  // Cod Instalacao 1
//      endif                        
//      if SM0->M0_CODFIL =  "03"
//         cLinha := cLinha + '0158429' // Cod Instalacao 1
//      endif

	   
	   cInstANP := '0000000'  // Cod Instalacao 2
	
	   cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	   cProOpe:= ESTOQUE->PROOPE
	   cQtdKg := ESTOQUE->QTDKGE
	
	   cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	   cQtdPro := Int(ESTOQUE->QTDEE)
	   cLinha  := cLinha + StrZero(cQtdPro,15)
	
	   cQtdKgl := int(cQtdKg)
	   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000
	
	   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   
	   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
	   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao
	
	   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	   cMun_ANP := '0000000' // Codigo Municipio
	
	   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro
	   
	   cLinha := cLinha + cMun_ANP // Codigo Municipio
	   cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
	   cLinha := cLinha + '0000' // Cod do país
	   cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	   cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
	   cDoc   := '0000000'    
	   cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	   cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
		
	   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
	   cLinha := cLinha + cDtEmi // Data da operacao Comercial
	   cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	   cFisQui1 := '000'
	   cMetodo1 := '000'
	   cUnMedi1 := '00'
	   cVlCara1 := '0000000000'
	   cMassaE1 := '0000000'
		
	   cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	   cRecGLP := '00'    // Recipiente de GLP
      cChaveNfe := "00000000000000000000000000000000000000000000"		
	   cLinhax := ''
	   If !Empty(cFisQui1) .and. cQtdPro > 0
	      cConta := cConta + 1  // Nr Registro
		   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe
	
		   SELE AGR159
	      Reclock("AGR159",.T.)
	      AGR159->SEQ    := cConta
	      AGR159->LIN    := cLinhax
	      MsUnlock("AGR159") 
	   Endif
   Endif   
   
   *
   * Reg. Inventario para Saida
   *      
   If nQTDEIN > 0 // Qtde inventario maior que zero eh qtdo teve mais entrada que saida, se faz ajuste SAIDA
      If nQTDKGIN < 0
         nQTDKGIN := nQTDKGIN * -1 // Se for qtde negativa torna positiva
      Endif
	   nQTDEINS  := nQTDEIN
	   nQTDKGINS := nQTDKGIN
	   Incproc()
	   cLinha := Space(01)
	   cOperac:= '0000000'
	
	  
	   cLinha := cAgeRegInf                   // Nr Agente Reg Informante
	   cLinha := cLinha + cMMAAAA              // Mes Referencia
	   
	   cOperac := '1022004' // Operacao para Perdas de Processo
	   
	   cLinha := cLinha + cOperac   // Operacao
	   
//	   if SM0->M0_CODFIL =  "01"
         cLinha := cLinha + cCodInst // Cod Instalacao 1
//      endif
//      if SM0->M0_CODFIL =  "02"
//         cLinha := cLinha + '1152416'  // Cod Instalacao 1
//      endif                        
//      if SM0->M0_CODFIL =  "03"
//         cLinha := cLinha + '0158429' // Cod Instalacao 1
//	   endif

	   
	   cInstANP := '0000000'  // Cod Instalacao 2
	
	   cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	   cProOpe:= ESTOQUE->PROOPE
	   cQtdKg := nQTDKGIN
	   If cQtdKg < 0 // Se for qtde negativa torna positiva
	      cQtdKg := cQtdKg * -1        
	   Endif
	
	   cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	   cQtdPro := Int(nQTDEIN)
	   cLinha  := cLinha + StrZero(cQtdPro,15)
	
	   cQtdKgl := int(cQtdKg)
	   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

	   If cQtdKgl == 0 .And. cQtdKgm < 0.001 // Caso Quilos e Miligramas zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   
	   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
	   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao
	
	   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	   cMun_ANP := '0000000' // Codigo Municipio
	
	   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro
	
		cLinha := cLinha + '0000000' // Codigo Municipio
		cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
		cLinha := cLinha + '0000' // Cod do país
		cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
		cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
		cDoc   := '0000000'    
		cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
		cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
		
	   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
		cLinha := cLinha + cDtEmi // Data da operacao Comercial
		cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	   cFisQui1 := '000'
	   cMetodo1 := '000'
	   cUnMedi1 := '00'
	   cVlCara1 := '0000000000'
	   cMassaE1 := '0000000'
		
		cProRes := '000000000' // Codigo do Produto/Operacao Resultante
		cRecGLP := '00'    // Recipiente de GLP
      cChaveNfe := "00000000000000000000000000000000000000000000"
      		
		cLinhax := ''
		If !Empty(cFisQui1) .and. cQtdPro > 0
	      cConta := cConta + 1  // Nr Registro
		   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe
	
		   SELE AGR159
	      Reclock("AGR159",.T.)
	      AGR159->SEQ    := cConta
	      AGR159->LIN    := cLinhax
	      MsUnlock("AGR159") 
		Endif
	Endif
   
   
   If nQTDEIN < 0 // Qtde inventario menor que zero eh qtdo teve mais Saida que Entrada, se faz ajuste ENTRADA
      nQTDEIN  := nQTDEIN  * -1
      If nQTDKGIN < 0
         nQTDKGIN := nQTDKGIN * -1 
      Endif
	   nQTDEINE  := nQTDEIN
	   nQTDKGINE := nQTDKGIN
      
	   Incproc()
	   cLinha := Space(01)
	   cOperac:= '0000000'
	
	  
	   cLinha := cAgeRegInf                   // Nr Agente Reg Informante
	   cLinha := cLinha + cMMAAAA              // Mes Referencia
	   
	   cOperac := '1021001' // Operacao para Sobras de processo
	   
	   cLinha := cLinha + cOperac   // Operacao
	   
//      if SM0->M0_CODFIL =  "01"
         cLinha := cLinha + cCodInst // Cod Instalacao 1
//      endif
//      if SM0->M0_CODFIL =  "02"
//         cLinha := cLinha + '1152416'  // Cod Instalacao 1
//      endif                        
//      if SM0->M0_CODFIL =  "03"
//         cLinha := cLinha + '0158429' // Cod Instalacao 1
//      endif
	   
	   cInstANP := '0000000'  // Cod Instalacao 2
	
	   cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	   cProOpe:= ESTOQUE->PROOPE
	   cQtdKg := nQTDKGIN        
	   If cQtdKg < 0 // Se for qtde negativa torna positiva
	      cQtdKg := cQtdKg * -1        
	   Endif
	
	   cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	   cQtdPro := Int(nQTDEIN)
	   cLinha  := cLinha + StrZero(cQtdPro,15)
	
	   cQtdKgl := int(cQtdKg)
	   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000
	   
	   If cQtdKgl == 0 .And. cQtdKgm < 0.001 // Caso Quilos e Miligramas zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   
	   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
	   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao
	
	   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	   cMun_ANP := '0000000' // Codigo Municipio
	
	   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro
	
		cLinha := cLinha + '0000000' // Codigo Municipio
		cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
		cLinha := cLinha + '0000' // Cod do país
		cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
		cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
		cDoc   := '0000000'    
		cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
		cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
		
	   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
		cLinha := cLinha + cDtEmi // Data da operacao Comercial
		cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	   cFisQui1 := '000'
	   cMetodo1 := '000'
	   cUnMedi1 := '00'
	   cVlCara1 := '0000000000'
	   cMassaE1 := '0000000'
		
		cProRes := '000000000' // Codigo do Produto/Operacao Resultante
		cRecGLP := '00'    // Recipiente de GLP                                                                                        
      cChaveNfe := "00000000000000000000000000000000000000000000"
		
		cLinhax := ''
		If !Empty(cFisQui1) .and. cQtdPro > 0
	      cConta := cConta + 1  // Nr Registro
		   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe
	
		   SELE AGR159
	      Reclock("AGR159",.T.)
	      AGR159->SEQ    := cConta
	      AGR159->LIN    := cLinhax
	      MsUnlock("AGR159") 
		Endif
	Endif
	
	
	If cTotEnt == '' // Caso nao tenha Registro inventario de Saida imprime agora total Entradas
	   *
	   * Total Entradas
	   *
	   Incproc()
	   cLinha := Space(01)
	   cOperac:= '0000000'
	
	  
	   cLinha := cAgeRegInf                   // Nr Agente Reg Informante
	   cLinha := cLinha + cMMAAAA              // Mes Referencia
	   
	   cOperac := '1011998' // Operacao para Total Entradas Comerciais Nacionais
	   
	   cLinha := cLinha + cOperac   // Operacao
	   
//      if SM0->M0_CODFIL =  "01"
         cLinha := cLinha + cCodInst    // Cod Instalacao 1
//      endif
//      if SM0->M0_CODFIL =  "02"
//         cLinha := cLinha + '1152416'  // Cod Instalacao 1
//      endif                        
//      if SM0->M0_CODFIL =  "03"
//         cLinha := cLinha + '0158429' // Cod Instalacao 1
//      endif

	   
	   cInstANP := '0000000'  // Cod Instalacao 2
	
	   cLinha := cLinha + cInstANP  // Cod Instalacao 2
	
	   cProOpe:= ESTOQUE->PROOPE
	   cQtdKg := ESTOQUE->QTDKGE
	
	   cLinha := cLinha + cProOpe // Cod Prod Operado
	   
	   cQtdPro := Int(ESTOQUE->QTDEE)
	   cLinha  := cLinha + StrZero(cQtdPro,15)
	
	   cQtdKgl := int(cQtdKg)
	   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000
	
	   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
	      cQtdKgm := 1
	   Endif
	   
	   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
	   
	   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
	   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
	   
	   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao
	
	   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
	   
	   cMun_ANP := '0000000' // Codigo Municipio
	
	   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro
	
		cLinha := cLinha + cMun_ANP // Codigo Municipio
		cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
		cLinha := cLinha + '0000' // Cod do país
		cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
		cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
		
		cDoc   := '0000000'    
		cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
		cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
		
	   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
		cLinha := cLinha + cDtEmi // Data da operacao Comercial
		cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
		
	   cFisQui1 := '000'
	   cMetodo1 := '000'
	   cUnMedi1 := '00'
	   cVlCara1 := '0000000000'
	   cMassaE1 := '0000000'
		
		cProRes := '000000000' // Codigo do Produto/Operacao Resultante
		cRecGLP := '00'    // Recipiente de GLP
      cChaveNfe := "00000000000000000000000000000000000000000000"
		
		cLinhax := ''
		If !Empty(cFisQui1) .and. cQtdPro > 0
	      cConta := cConta + 1  // Nr Registro
		   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe
	
		   SELE AGR159
	      Reclock("AGR159",.T.)
	      AGR159->SEQ    := cConta
	      AGR159->LIN    := cLinhax
	      MsUnlock("AGR159") 
		Endif
	Endif


   *
   * Total Saidas
   *
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := cAgeRegInf                   // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '1012998' // Operacao para Total Saidas Comerciais Nacionais
   
   cLinha := cLinha + cOperac   // Operacao
   
//   if SM0->M0_CODFIL =  "01"
      cLinha := cLinha + cCodInst // Cod Instalacao 1
//   endif
//   if SM0->M0_CODFIL =  "02"
//       cLinha := cLinha + '1152416'  // Cod Instalacao 1
 //  endif                        
//   if SM0->M0_CODFIL =  "03"
//       cLinha := cLinha + '0158429' // Cod Instalacao 1
//   endif
   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := ESTOQUE->QTDKGS

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDES)
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + cMun_ANP // Codigo Municipio
	cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	cRecGLP := '00'    // Recipiente de GLP
   cChaveNfe := "00000000000000000000000000000000000000000000"                                                                                                                                  
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif


   *
   * Total Transferencia Entradas
   *
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := cAgeRegInf                  // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '1021998' // Operacao para Total Entradas Operacionais (Transferencia Entradas)
   
   cLinha := cLinha + cOperac   // Operacao
   
//   if SM0->M0_CODFIL =  "01"
      cLinha := cLinha + cCodInst    // Cod Instalacao 1
//   endif
//   if SM0->M0_CODFIL =  "02"
//      cLinha := cLinha + '1152416'  // Cod Instalacao 1
//   endif                        
//   if SM0->M0_CODFIL =  "03"
//      cLinha := cLinha + '0158429' // Cod Instalacao 1
//  endif

   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := (ESTOQUE->QTDKGTE + nQTDKGINE ) // Soma inventario de entrada caso tenha

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDETE + nQTDEINE) // Soma inventario de entrada caso tenha
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + '0000000' // Codigo Municipio
	cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	cRecGLP := '00'    // Recipiente de GLP                                                                                        
   cChaveNfe := "00000000000000000000000000000000000000000000"
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif
   *
   * Total Transferencia Saidas
   *
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := cAgeRegInf                  // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '1022998' // Operacao para Total Saidas Operacionais (Transferencia Saidas)
   
   cLinha := cLinha + cOperac   // Operacao
   
//   if SM0->M0_CODFIL =  "01"
      cLinha := cLinha + cCodInst // Cod Instalacao 1
//   endif
//   if SM0->M0_CODFIL =  "02"
//      cLinha := cLinha + '1152416'  // Cod Instalacao 1
//   endif                        
//   if SM0->M0_CODFIL =  "03"
//      cLinha := cLinha + '0158429' // Cod Instalacao 1
//   endif

   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := (ESTOQUE->QTDKGTS + nQTDKGINS ) // Soma inventario de saida caso tenha

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDETS + nQTDEINS ) // Soma inventario de saida caso tenha
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + '0000000' // Codigo Municipio
	cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante                                                                
	cRecGLP := '00'    // Recipiente de GLP                                                                                        
   cChaveNfe := "00000000000000000000000000000000000000000000"
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif                           
//**********************************************************************************
// TOTAL TRANSFERENCIA ENTRADA FILIAIS      
IF 1 =1 
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := cAgeRegInf                  // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '1051998' // TOTAL DAS ENTRADAS TRANSFERENCIA ENTRE FILIAIS
   
   cLinha := cLinha + cOperac   // Operacao
   
//   if SM0->M0_CODFIL =  "01"
      cLinha := cLinha + cCodInst // Cod Instalacao 1
//   endif
//   if SM0->M0_CODFIL =  "02"
//     cLinha := cLinha + '1152416'  // Cod Instalacao 1
//   endif                        
//   if SM0->M0_CODFIL =  "03"
//      cLinha := cLinha + '0158429' // Cod Instalacao 1
//   endif

   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := (ESTOQUE->QTDETEF)// + nQTDKGIN ) // Soma inventario de saida caso tenha
   

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDETEF) //+ nQTDEIN ) // Soma inventario de saida caso tenha
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + '0000000' // Codigo Municipio
	cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	cRecGLP := '00'    // Recipiente de GLP
   cChaveNfe := "00000000000000000000000000000000000000000000"
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif  	
ENDIF	
	
	//********************************************************************************
	//********************************************************************************
	
//**********************************************************************************
// TOTAL TRANSFERENCIA SAIDAS FILIAIS
IF 1 =1 
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := cAgeRegInf                   // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '1052998' // Operacao para Total Saidas transferencia filiais (Transferencia saidas)
   
   cLinha := cLinha + cOperac   // Operacao
   
//   if SM0->M0_CODFIL =  "01"
      cLinha := cLinha + cCodInst    // Cod Instalacao 1
//   endif
//   if SM0->M0_CODFIL =  "02"
//      cLinha := cLinha + '1152416'  // Cod Instalacao 1
//   endif                        
//   if SM0->M0_CODFIL =  "03"
//      cLinha := cLinha + '0158429' // Cod Instalacao 1
//   endif

   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := (ESTOQUE->QTDETSF )//+ nQTDKGIN ) // Soma inventario de saida caso tenha

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDETSF )// + nQTDEIN ) // Soma inventario de saida caso tenha
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + '0000000' // Codigo Municipio
	cLinha := cLinha + '00000' // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	cRecGLP := '00'    // Recipiente de GLP                                                                                        
   cChaveNfe := "00000000000000000000000000000000000000000000"
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif  	
	
ENDIF	
	//********************************************************************************
	//********************************************************************************
	
	
	
   *
   * Total Geral Entradas
   *
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := cAgeRegInf                   // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '4011998' // Operacao para Total Geral Entradas
   
   cLinha := cLinha + cOperac   // Operacao
   
//   if SM0->M0_CODFIL =  "01"
      cLinha := cLinha + cCodInst    // Cod Instalacao 1
//   endif
//   if SM0->M0_CODFIL =  "02"
//      cLinha := cLinha + '1152416'  // Cod Instalacao 1
//   endif                        
//   if SM0->M0_CODFIL =  "03"
//      cLinha := cLinha + '0158429' // Cod Instalacao 1
//   endif                         
   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := ESTOQUE->QTDKGE + ESTOQUE->QTDKGTE + nQTDKGINE  // Soma inventario de entrada caso tenha

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDEE) + Int(ESTOQUE->QTDETE) + int(nQTDEINE ) // Soma inventario de entrada caso tenha
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + StrZero(cQtdPro,15) // Strzero(cQtdKgl,12)+StrZero(cQtdKgm,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + cMun_ANP // Codigo Municipio
	cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	cRecGLP := '00'    // Recipiente de GLP                                                                                        
   cChaveNfe := "00000000000000000000000000000000000000000000"
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif
   *
   * Total Geral Saidas
   *
   Incproc()
   cLinha := Space(01)
   cOperac:= '0000000'

  
   cLinha := cAgeRegInf                   // Nr Agente Reg Informante
   cLinha := cLinha + cMMAAAA              // Mes Referencia
   
   cOperac := '4012998' // Operacao para Total Geral Saidas
   
   cLinha := cLinha + cOperac   // Operacao
   
//   if SM0->M0_CODFIL =  "01"
      cLinha := cLinha + cCodInst    // Cod Instalacao 1
//   endif
//   if SM0->M0_CODFIL =  "02"
//     cLinha := cLinha + '1152416'  // Cod Instalacao 1
//   endif                        
//   if SM0->M0_CODFIL =  "03"
//      cLinha := cLinha + '0158429' // Cod Instalacao 1
//   endif
   
   cInstANP := '0000000'  // Cod Instalacao 2

   cLinha := cLinha + cInstANP  // Cod Instalacao 2

   cProOpe:= ESTOQUE->PROOPE
   cQtdKg := ESTOQUE->QTDKGS + ESTOQUE->QTDKGTS + nQTDKGINS  // Soma inventario de saida caso tenha

   cLinha := cLinha + cProOpe // Cod Prod Operado
   
   cQtdPro := Int(ESTOQUE->QTDES) + Int(ESTOQUE->QTDETS) + int(nQTDEINS ) // Soma inventario de saida caso tenha
   cLinha  := cLinha + StrZero(cQtdPro,15)

   cQtdKgl := int(cQtdKg)
   cQtdKgm := (cQtdKg - int(cQtdKg)) * 1000

   If cQtdKgl == 0 .And. cQtdKgm < 0.001  // Se Quilos e Miligrama igual a Zero Movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   If cQtdKgm < 0  // Caso Miligramas menor que zero movimenta 1 miligrama
      cQtdKgm := 1
   Endif
   
   cLinha := cLinha + StrZero(cQtdPro,15) //Strzero(cQtdKgl,12)+StrZero(m,3) // Qtde do produto Quilogramas (Quilos + Miligramas)
   
   cLinha := cLinha + '1' // Cod Modal Utilizado na Movimentacao 1 = Rodoviario
   cLinha := cLinha + '0000000' // Cod Veiculo utilizado no Modal (Nao se aplica, somente qdo maritimo ou dutoviario)
   
   cIdent := '00000000000000'  // Identificacao do terceiro envolvido na operacao

   cLinha := cLinha + cIdent // Identificacao do terceiro envolvido na operacao
   
   cMun_ANP := '0000000' // Codigo Municipio

   cAtivida := '00000'  // Codigo Atividade Economica do Terceiro

	cLinha := cLinha + cMun_ANP // Codigo Municipio
	cLinha := cLinha + cAtivida // Codigo Atividade Economica do Terceiro
	cLinha := cLinha + '0000' // Cod do país
	cLinha := cLinha + '0000000000' // Numero da Liberacao de importacao
	cLinha := cLinha + '0000000000' // Numero da Declaracao de importacao (DI)
	
	cDoc   := '0000000'    
	cLinha := cLinha + cDOC // Nr da NF da operacao Comercial
	cLinha := cLinha + '00' // Cod Serie da NF da operacao comercial 04 = Unica    
	
   cDtEmi := strzero(day(MV_PAR02),2)+strzero(month(MV_PAR02),2)+strzero(year(MV_PAR02),4)	
	cLinha := cLinha + cDtEmi // Data da operacao Comercial
	cLinha := cLinha + '0' // Cod Servico Acordado (Dutos)
	
   cFisQui1 := '000'
   cMetodo1 := '000'
   cUnMedi1 := '00'
   cVlCara1 := '0000000000'
   cMassaE1 := '0000000'
	
	cProRes := '000000000' // Codigo do Produto/Operacao Resultante
	cRecGLP := '00'    // Recipiente de GLP
    cChaveNfe := "00000000000000000000000000000000000000000000"
	
	cLinhax := ''
	If !Empty(cFisQui1) .and. cQtdPro > 0
      cConta := cConta + 1  // Nr Registro
	   cLinhax:= StrZero(cConta,10) + cLinha + cFisQui1 + cMetodo1 + cUnMedi1 + cVlCara1 + cProRes + cMassaE1 + cRecGLP + cChaveNfe

	   SELE AGR159
      Reclock("AGR159",.T.)
      AGR159->SEQ    := cConta
      AGR159->LIN    := cLinhax
      MsUnlock("AGR159") 
	Endif
	
	   
   Sele ESTOQUE
   DbSkip()

End

*
* Gera Registro Controle
*  
cConta := cConta + 1 // Adiciona 1 devido Header ser linha 0
cLinha := '0000000000'+ cAgeRegInf +cMMAAAA+StrZero(cConta,7)
fWrite(nHdlArq,cLinha+chr(13)+chr(10),len(cLinha)+2)
*
* Gera Registro Movimentacao
*  
SELE AGR159             
DbGotop()
While !Eof()
   cLinhax := AGR159->LIN     
   fWrite(nHdlArq,cLinhax+chr(13)+chr(10),len(cLinhax)+2)
   DbSkip()
   Loop
End
FClose(nHdlArq)

*
* Imprimi Relatorio Resumido cfe necessidade Fabi
*
AGR159REL()

sele SA1
dbsetorder(1) ; dbgotop()

SELE MSD2
USE

SELE MSD1
USE

SELE AGR159
USE

SELE ESTOQUE
USE

RETURN


Static Function AGR159REL()
	Limite   := 132
	cString  :="SB2"
	cDesc1   := OemToAnsi("Este programa tem como objetivo, imprimir o relatorio")
	cDesc2   := OemToAnsi("Resumido da Geracao do Arquivo SIMP")
	cDesc3   := ""
	nChar    := 18
	cTamanho := "M"
	
	aReturn  := {OemToAnsi("Zebrado"),1,OemToAnsi("Administracao"),2,2,1,"",1}
	cNomeProg:= "AGR159"
	aLinha   := {}
	nLastKey := 0
	
	Titulo   := "Relatorio Resumido Arquivo SIMP De: " + DTOC(MV_PAR01) + " Ate: " + DTOC(MV_PAR02)
	cCabec1  := "                                            ENTRADAS       TOTAL                        SAIDAS         TOTAL               "
	//				 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//				           10        20        30        40        50        60        70        80        90        100       110       120       130
	cCabec2  := "PRODUTO    SALDO INICIAL       COMPRAS      PRODUCAO      ENTRADAS        VENDAS      PRODUCAO        SAIDAS    SALDO FINAL"
	cCancel  := "***** CANCELADO PELO OPERADOR *****"
	m_pag    := 1        //Variavel que acumula numero da pagina
	wnrel    := "AGR159" //Nome Default do relatorio em Disco
	
	SetPrint(cString,wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	RptStatus({|lEnd| AGR159IMP(@lEnd,wnrel,cString)},Titulo)
Return

Static Function AGR159IMP()
	LOCAL nLin     := 99

	Sele ESTOQUE
	DbGotop()
	Procregua(Reccount())
	While !Eof() 
		If nLin > 55
			nLin := Cabec(Titulo,cCabec1,cCabec2,cNomeProg,cTamanho,nChar)
		Endif
		
		nLin++
		@ nLin,000 PSAY Alltrim(ESTOQUE->PROOPE)
		@ nLin,011 PSAY TRANSFORM(ESTOQUE->QTDEI,'@E 999,999,999.99')  // Estoque Inicial
		@ nLin,025 PSAY TRANSFORM(ESTOQUE->QTDEE,'@E 999,999,999.99')  // Compras = Total Entradas 
		@ nLin,039 PSAY TRANSFORM(ESTOQUE->QTDETE,'@E 999,999,999.99') // Producao Entradas = Transf. Entradas
		@ nLin,053 PSAY TRANSFORM((ESTOQUE->QTDEE+ESTOQUE->QTDETE),'@E 999,999,999.99') // Total Entradas
		@ nLin,067 PSAY TRANSFORM(ESTOQUE->QTDES,'@E 999,999,999.99')  // Vendas  = Total Saidas 
		@ nLin,081 PSAY TRANSFORM(ESTOQUE->QTDETS,'@E 999,999,999.99') // Producao Saidas = Transf. Saidas
		@ nLin,095 PSAY TRANSFORM((ESTOQUE->QTDES+ESTOQUE->QTDETS),'@E 999,999,999.99') // Total Saidas
		@ nLin,109 PSAY TRANSFORM(ESTOQUE->QTDEF,'@E 999,999,999.99') // Estoque Final

	   Sele ESTOQUE
   	DbSkip()

	End
	
	Roda(0,"",cTamanho)
	
	Set Filter To
	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel) //Chamada do Spool de Impressao
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool

Return

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