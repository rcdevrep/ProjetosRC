#include "rwmake.ch"
#include "topconn.ch"


//-------------------------------------------------------------------
/*/{Protheus.doc} XAG0098
Função para gerar EDI de Pedidos de venda
para a Agricopel.
Integração Maxton
@author Júnior Conte
@since 23/12/2022
@version 1.0

/*/
//-------------------------------------------------------------------

User Function XAG0098()

AtuSX1()

If cFilant <> '19'
    Alert('Rotina exclusiva para a Filial 19! ')
    Return
Endif
 
If Pergunte("XAG0098",.T.) == .F.
   Return
Endif
// mv_par01 -  Data De           
// mv_par02 -  Data Fim
// mv_par03 -  Arquivo de Saida
// mv_par04 -  Pedido de 
// mv_par05 -  Pedido ate
gerapedidos( .f. )

//MSGSTOP("Exportacao Efetuada com Sucesso!")
Return



//scheduler
user function XAG0098SCH
RpcSetType(3)
RpcSetEnv("01","19")  


//ddatabase :=  stod("20221222")

gerapedidos( .t. )

RPCClearEnv()

return

/*/

/*/

Static Function gerapedidos(lsch)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cEOL    := CHR(13)+CHR(10)
//Private nHdl    := fCreate(TRIM(MV_PAR03)+".TXT")

Private nTotal       := 0
Private aTotNota     := {}



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lsch
Processa({|| RunCont(lsch) },"Processando...")
else
RunCont(lsch)
endif
Return


Static Function RunCont(lsch)


if !lsch
    if FWIsAdmin(__cuserid) .and. !lsch //Se for admin deixa escolher o diretorio
        If MsgYesNo('Deseja salvar diretamente no ftp? ', 'Salvar arquivo')  
            _cPath := "\maxton\remessa\new\"
        Else   
            _cPath := cGetFile( "Arquivos de Exportacao Corpem | ",OemToAnsi("Selecione Diretorio"), ,"" ,.T.,GETF_LOCALHARD + GETF_RETDIRECTORY)
            If alltrim(_cPath) == ''
                Return
            Endif 
        Endif
    Else
        _cPath := "\maxton\remessa\new\"
    Endif 
else
    _cPath := "\maxton\remessa\new\"
endif

conout("XAG0098S - Importacao Arquivos CONF Inicio: "+DTOC(Date())+" "+Time())


_aTotTESCFO := {}

/*
_cQry :=  "SELECT DISTINCT  F2_FILIAL, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_DOC, F2_SERIE, D2_PEDIDO, F2_VALBRUT, D2_PEDIDO, A1_NOME, A1_CGC,A1_MUN, A1_CEP, A1_EST, A1_BAIRRO,A1_END, A4_CGC  "
_cQry := _cQry + "FROM " + RETSQLNAME("SF2") + " F2 "
_cQry := _cQry + " INNER JOIN " + RETSQLNAME("SD2") + " D2 ON D2.D2_FILIAL = F2.F2_FILIAL  "
_cQry := _cQry + "      AND D2.D2_DOC  = F2.F2_DOC AND D2.D2_SERIE  = F2.F2_SERIE "
_cQry := _cQry + "      AND D2.D2_CLIENTE  = F2.F2_CLIENTE AND D2.D2_LOJA  = F2.F2_LOJA "
_cQry := _cQry + " INNER JOIN " + RETSQLNAME("SA1") + " A1 ON A1.A1_FILIAL = '"+xFilial("SA1")+"'  "
_cQry := _cQry + "      AND  A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA "
_cQry := _cQry + " LEFT JOIN " + RETSQLNAME("SA4") + " A4 ON A4.A4_FILIAL = '"+xFilial("SA4")+"'  "
_cQry := _cQry + "      AND  A4.A4_COD = F2.F2_TRANSP "
_cQry := _cQry + " WHERE F2.D_E_L_E_T_<> '*'  And D2.D_E_L_E_T_<> '*'  And A1.D_E_L_E_T_<> '*'  And A1.D_E_L_E_T_<> '*'  "
_cQry := _cQry +" And F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' And  '"+dtos(MV_PAR02) + "' "
_cQry := _cQry +" And D2_PEDIDO  BETWEEN '"+mv_par03+"' And  '" + MV_PAR04 + "' "
_cQry := _cQry +" And D2_FILIAL  BETWEEN '"+mv_par05+"' And  '" + MV_PAR06 + "' "

*/

_cQry :=  "SELECT  C9_FILIAL, C9_PEDIDO, C9_CLIENTE, C9_LOJA , C9_XHREDI, C9_DATALIB, SUM(C9_QTDLIB) C9_QTDLIB , SUM(C9_PRCVEN) C9_PRCVEN  "
_cQry := _cQry + "FROM " + RETSQLNAME("SC9") + " C9 "
_cQry := _cQry + " INNER JOIN " + RETSQLNAME("SA1") + " (NOLOCK) A1 ON A1.A1_FILIAL = '"+xFilial("SA1")+"'  "
_cQry := _cQry + "      AND  A1.A1_COD = C9.C9_CLIENTE AND A1.A1_LOJA = C9.C9_LOJA "
_cQry := _cQry + " INNER JOIN " + RETSQLNAME("SC6") + "(NOLOCK) C6 ON C6.C6_FILIAL = C9.C9_FILIAL   "
_cQry := _cQry + "      AND  C6.C6_CLI = C9.C9_CLIENTE AND C6.C6_LOJA = C9.C9_LOJA   AND C6.C6_NUM = C9.C9_PEDIDO  AND C6.C6_PRODUTO = C9.C9_PRODUTO  AND C6.C6_ITEM = C9.C9_ITEM"
_cQry := _cQry + " INNER JOIN " + RETSQLNAME("SB1") + "(NOLOCK) B1 ON C6.C6_FILIAL = B1.B1_FILIAL   "
_cQry := _cQry + "      AND  C6.C6_PRODUTO = B1.B1_COD "
_cQry := _cQry + " WHERE    B1.D_E_L_E_T_ <> '*' AND C9.D_E_L_E_T_<> '*'   And A1.D_E_L_E_T_<> '*' And C9.C9_BLEST IN (' ', 'ZZ', '10')  And C9.C9_BLCRED IN (' ', 'ZZ','10')   "
_cQry := _cQry + " And NOT (trim(C9_PRODUTO)  LIKE '%801' AND B1_TIPO = 'SH'  )  AND B1_TIPO IN ('PA','SH','AE','QR') "//Não envia Granel
if !lsch
    _cQry := _cQry +" And C9_DATALIB BETWEEN '"+dtos(MV_PAR01)+"' And  '"+dtos(MV_PAR02) + "' "
    _cQry := _cQry +" And C9_PEDIDO  BETWEEN '"+mv_par03+"' And  '" + MV_PAR04 + "' "
    _cQry := _cQry +" And C9_LOCAL  BETWEEN '"+mv_par05+"' And  '" + MV_PAR06 + "' "
    _cQry := _cQry +" And C9_FILIAL  = '19' AND C9_XSREDI = ' ' AND C9_XDTEDI = ' ' AND  C9_XHREDI = ' ' "
else
    _cQry := _cQry +" And C9_DATALIB BETWEEN ''  And  '"+dtos(ddatabase) + "' " 
    //_cQry := _cQry +" And C9_FILIAL  = '19' AND C9_XDTEDI = ' ' AND  C9_XHREDI = ' ' "    
    _cQry := _cQry +" And C9_FILIAL  = '19' AND C9_XSREDI = ' ' AND C9_XDTEDI = ' ' AND  C9_XHREDI = ' ' "
    _cQry := _cQry +" And C9_LOCAL   = '01' AND (C6_ENTREG <= '"+dtos(ddatabase)+"' OR C6_ENTREG = '') "   //Schedule só envia pedidos da Franquia
endif
_cQry := _cQry +" Group By  C9_FILIAL, C9_PEDIDO, C9_CLIENTE, C9_LOJA,C9_XHREDI,  C9_DATALIB "

//CONOUT(_cQry)

If Select("CABEC") > 0
    dbSelectArea("CABEC")                   
    DbCloseArea()
EndIf

//* Cria a Query e da Um Apelido
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"CABEC",.F.,.T.)


dbSelectArea("CABEC")
dbGotop()

cHeader   := ""

nContador := 0
cLin      := ""  	

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt,.T.)

cArquivo := ""


WHILE CABEC->(!EOF() )  

	IF EMPTY(ALLTRIM(CABEC->C9_XHREDI))

        if empty(cHeader)
            cHeader := "0" + TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99") + SUBSTR(DTOS(DDATABASE), 7, 2) + "/"+ SUBSTR(DTOS(DDATABASE), 5, 2)  + "/"+ SUBSTR(DTOS(DDATABASE), 1, 4)
            cHeader += TIME() + cEOL
            nContador := nContador + 1
        endif

        DbSelectArea("SA1")
        DbSetOrder(1)
        dbseek(xFilial("SA1") + CABEC->C9_CLIENTE +  CABEC->C9_LOJA  )
    
    

        //******************  REGISTRO CABEÇALHO  *************************************
        cLin := cLin + "1"  
        cLin := cLin +  TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99")    																									// 1
        cLin := cLin + "2"                        // 2
        cLin := cLin +  TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99")    
        cLin := cLin + padr(CABEC->C9_PEDIDO , 10)

        cSer := sfbusser( CABEC->C9_PEDIDO, CABEC->C9_FILIAL )
        cLin := cLin + cSer

           	
    // cLin := cLin + padr(CABEC->F2_SERIE , 2)  																							// 3
        cLin := cLin + SUBSTR(CABEC->C9_DATALIB, 7, 2) + "/"+ SUBSTR(CABEC->C9_DATALIB, 5, 2) +"/"+ SUBSTR(CABEC->C9_DATALIB, 1, 4)																							// 4
        cLin := cLin + "000000000000001000"    	
        cLin := cLin + space(18) //"000000000000000000"								// 5
    // cLin := cLin + 	STRZERO(TRANSFORM(CABEC->F2_VALBRUT , "@E 9999999.99"), 10) 	
    
    // cLin := cLin + padr(strtran(cValTochar(CABEC->C9_QTDLIB * CABEC->C9_PRCVEN), ".", ""), 17, "0")		
        cLin := cLin + padl(cValTochar(INT(( CABEC->C9_QTDLIB * CABEC->C9_PRCVEN ) * 100 )), 17, "0")																	// 6
        //cLin := cLin + padr(CABEC->D2_PEDIDO , 30)  	
        //cLin := cLin + padr(CABEC->A1_NOME   , 50) 	
        //cLin := cLin + padr(CABEC->A1_CGC    , 14) 	
        //cLin := cLin + padr(CABEC->A1_CEP    , 8) 	
        //cLin := cLin + padr(CABEC->A1_EST     , 2) 	
        //cLin := cLin + padr(CABEC->A1_MUN    , 40) 																							// 7
        //cLin := cLin + padr(CABEC->A1_BAIRRO , 30) 
        //cLin := cLin + padr(CABEC->A1_END    , 60) 
        //cLin := cLin + SPACE(10)
        //cLin := cLin + SPACE(50)
        cLin := cLin + SPACE(140)
        //cLin := cLin + padr(CABEC->A4_CGC    , 14) 
                                                                                            // 12
        cLin := cLin + cEOL
        //nContTrans:= nContTrans + 1


        nContador := nContador + 1

        


        _cQryI :=  "SELECT *  "
        _cQryI := _cQryI + "FROM " + RETSQLNAME("SC9") + " C9 "
        _cQryI := _cQryI + " INNER JOIN " + RETSQLNAME("SB1") + "(NOLOCK) B1 ON C9.C9_FILIAL = B1.B1_FILIAL   "
        _cQryI := _cQryI + "      AND  C9.C9_PRODUTO = B1.B1_COD "
        _cQryI := _cQryI + " INNER JOIN " + RETSQLNAME("SC6") + "(NOLOCK) C6 ON  C9.C9_FILIAL = C6.C6_FILIAL "
        _cQryI := _cQryI + "      AND  C9.C9_PEDIDO = C6.C6_NUM AND C9.C9_ITEM = C6.C6_ITEM AND C6.D_E_L_E_T_ = '' "
          _cQryI := _cQryI + " WHERE B1.D_E_L_E_T_ <> '*' AND C9.C9_FILIAL = '"+CABEC->C9_FILIAL+"'     And C9.C9_BLEST IN (' ', 'ZZ','10')  And C9.C9_BLCRED IN (' ', 'ZZ','10')  "
        _cQryI := _cQryI +"  And C9.D_E_L_E_T_<> '*' And C9_PEDIDO = '"+CABEC->C9_PEDIDO+"' AND C9_XDTEDI = ' ' AND  C9_XHREDI = ' ' AND C9_XSREDI = ' '  "
		if lsch 
            _cQryI := _cQryI +" And C9_LOCAL   = '01' AND (C6_ENTREG <= '"+dtos(ddatabase)+"' OR C6_ENTREG = '')  "
        Else
             _cQryI := _cQryI  +" And C9_LOCAL  BETWEEN '"+mv_par05+"' And  '" + MV_PAR06 + "' "
        Endif 
       
        _cQryI := _cQryI +"  And NOT (trim(C9_PRODUTO)  LIKE '%801' AND B1_TIPO = 'SH'  )  AND B1_TIPO IN ('PA','SH','AE','QR') "//Não envia Granel
        
        If Select("ITEM") > 0
            dbSelectArea("ITEM")                   
            DbCloseArea()
        EndIf

        //* Cria a Query e da Um Apelido
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryI),"ITEM",.F.,.T.)


        dbSelectArea("ITEM")
        dbGotop()
            
        WHILE ITEM->(!EOF() )
        
            SB1->(dbSeek(xFilial("SB1")+ITEM->C9_PRODUTO ))
            cLin := cLin + "2" 
            cLin := cLin +  TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99")   
            cLin := cLin + "2"                        // 2
            cLin := cLin +  TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99")    
            cLin := cLin + padr(CABEC->C9_PEDIDO , 10)
            cLin := cLin + cSer// "PED"     	 		 						// 1
            cLin := cLin + padr(ITEM->C9_PRODUTO , 20 )					// 2
            cLin := cLin + SPACE(12)    
        // cLin := cLin + padl(strtran(cValTochar(round(ITEM->C9_PRCVEN , 2)), ".", ""), 17, "0")
            cLin := cLin + padl(cValTochar(int(ITEM->C9_PRCVEN * 100)), 17, "0")
            cLin := cLin + "000000000000001000"    	
            //cLin := cLin + padl(strtran(cValTochar(round(ITEM->C9_QTDLIB, 2)), ".", ""), 18, "0")
            cLin := cLin + padl(cValTochar(int(ITEM->C9_QTDLIB * 1000)), 18, "0")
            cLin := cLin + SPACE(20)  

            CDESCARM := POSICIONE("NNR", 1, xFilial("NNR") + ITEM->C9_LOCAL, "NNR_DESCRI" )

            IF alltrim(ITEM->C9_LOCAL) == '20' .OR. alltrim(ITEM->C9_LOCAL) == '27'  //ALLTRIM(CDESCARM) == "ALVORADA"
                cLin := cLin + PADR( 'Z080' , 20)
            ELSEIF alltrim(ITEM->C9_LOCAL) == '01' //ALLTRIM(CDESCARM) ==  "ARMAZEM 01 LUBS" 
                cLin := cLin + PADR( 'Z030', 20)
            ELSE
                cLin := cLin + PADR( SUBSTR( alltrim(ITEM->C9_LOCAL)+''+alltrim(CDESCARM)  , 1, 20), 20)
            ENDIF

            cLin := cLin + "N"  
            
        
            //cLin := cLin + left("00"+SB1->B1_POSIPI+"0000000000",10)			// 7
            //cLin := cLin + strzero((round(ITEM->D2_IPI,2)*100),4) 				// 8
            //cLin := cLin + 	STRZERO(TRANSFORM(CABEC->D2_PRCVEN , "@E 9999999.99"), 10) 	
            
            //cLin := cLin + strzero((round(ITEM->D2_QUANT,2)*100),9)				// 10
            //cLin := cLin + LEFT(ITEM->D2_UM+SPACE(2),2)							// 11
            //cLin := cLin + strzero((round(ITEM->D2_QUANT,2)*100),9)				// 12
            //cLin := cLin + LEFT(ITEM->D2_UM+SPACE(2),2)							// 13
        //	cLin := cLin + "P"													// 14
            //cLin := cLin + strzero((round(ITEM->D2_DESC,2)*100),4)		  		// 15
            //cLin := cLin + strzero((round(ITEM->D2_TOTAL,2)*100),11) 			// 16
            //cLin := cLin + SPACE(04)											// 17
            //cLin := cLin + SPACE(01)                                        	// 18
            cLin := cLin + cEOL                                             	// 19

        

            nContador := nContador + 1


            DbSelectArea("SC6")
            DbSetOrder(1)
                                                                                                                                
            if  DbSeek( ITEM->C9_FILIAL +  ITEM->C9_PEDIDO + ITEM->C9_ITEM + ITEM->C9_PRODUTO)
                RecLock("SC6", .F.)
                    SC6->C6_XDTEDI :=  DDATABASE
                    SC6->C6_XHREDI :=  SUBSTR( TIME(), 1,5)
                MsUnlock()
            endif

            DbSelectArea("SC9")
            DbSetOrder(1)

            if empty(cArquivo)

                nDia := STRZERO(DAY( DATE() ) , 2)
                cMes := ""
                DO CASE

                    CASE MONTH(DATE()) == 1
                        cMes := "A"
                    CASE MONTH(DATE()) == 2
                        cMes := "B"
                    CASE MONTH(DATE()) == 3
                        cMes := "C"
                    CASE MONTH(DATE()) == 4
                        cMes := "D"
                    CASE MONTH(DATE()) == 5
                        cMes := "E"
                    CASE MONTH(DATE()) == 6
                        cMes := "F"
                    CASE MONTH(DATE()) == 7
                        cMes := "G"
                    CASE MONTH(DATE()) == 8
                        cMes := "H"
                    CASE MONTH(DATE()) == 9
                        cMes := "I"
                    CASE MONTH(DATE()) == 10
                        cMes := "J"
                    CASE MONTH(DATE()) == 11
                        cMes := "K"
                    CASE MONTH(DATE()) == 12
                        cMes := "L"

                ENDCASE


                cDtAtu := GetMV("AG_DTMAXTO")

                cSeq   := GetMV("AG_SEQ")

                if alltrim(dtos(ddatabase)) >  alltrim(cDtAtu)
                    PutMv("AG_DTMAXTO",DTOS(dDatabase))
                    PutMv("AG_SEQ","001")
                    cSeq   := GetMV("AG_SEQ")
         
                else
                    cSeq := soma1(cSeq)
                    PutMv("AG_SEQ",cSeq)

                endif


                cAno    := substr( dtos(DDATABASE), 3, 2)

                cArquivo := "AG"+ "S" + nDia + cMes + cAno +"."+alltrim(cSeq)
                //nHdl    := fCreate(TRIM(_cPath)+ "AG"+ "S" + nDia + cMes + cAno +"."+alltrim(cSeq))

            endif 

            if  DbSeek( ITEM->C9_FILIAL +  ITEM->C9_PEDIDO + ITEM->C9_ITEM + ITEM->C9_SEQUEN  + ITEM->C9_PRODUTO)
                
                RecLock("SC9", .F.)
                    SC9->C9_XDTEDI  :=  DDATABASE
                    SC9->C9_XHREDI  :=  SUBSTR( TIME(), 1,5)
                    SC9->C9_XSREDI  := cSer
                    SC9->C9_XARQEDI := cArquivo
                MsUnlock()

            endif

    

            dbSelectArea("ITEM")
            ITEM->(DbSkip())       

        EndDo
    ENDIF



    dbSelectArea("CABEC")
	CABEC->(DbSkip())       

ENDDO
    IF !EMPTY(cLin)
        
        cLin := cLin + "9" + padl(cValTochar( nContador + 1), 5, "0")  +  cEOL 

        cLin := cHeader + cLin
        /*
        nDia := STRZERO(DAY( DATE() ) , 2)
        cMes := ""
        DO CASE

            CASE MONTH(DATE()) == 1
                cMes := "A"
            CASE MONTH(DATE()) == 2
                cMes := "B"
            CASE MONTH(DATE()) == 3
                cMes := "C"
            CASE MONTH(DATE()) == 4
                cMes := "D"
            CASE MONTH(DATE()) == 5
                cMes := "E"
            CASE MONTH(DATE()) == 6
                cMes := "F"
            CASE MONTH(DATE()) == 7
                cMes := "G"
            CASE MONTH(DATE()) == 8
                cMes := "H"
            CASE MONTH(DATE()) == 9
                cMes := "I"
            CASE MONTH(DATE()) == 10
                cMes := "J"
            CASE MONTH(DATE()) == 11
                cMes := "K"
            CASE MONTH(DATE()) == 12
                cMes := "L"

        ENDCASE


        cDtAtu := GetMV("AG_DTMAXTO")

        cSeq   := GetMV("AG_SEQ")

        if alltrim(dtos(ddatabase)) >  alltrim(cDtAtu)
            PutMv("AG_DTMAXTO",DTOS(dDatabase))
            PutMv("AG_SEQ","001")
            cSeq   := GetMV("AG_SEQ")
    // endif

    //  if alltrim(dtos(ddatabase)) ==  alltrim(cDtAtu)
        else
            cSeq := soma1(cSeq)
            PutMv("AG_SEQ",cSeq)

        endif

        //AG_DTMAXTO

        //AG_SEQ    

        cAno    := substr( dtos(DDATABASE), 3, 2)

        */
        nHdl    := fCreate( TRIM(_cPath)+ cArquivo )
        
        //alert(nHdl)

    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
        //³ linha montada.                                                      ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
            //If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
                //Exit
            //ndif
        else
        // MsgInfo("Criado arquivo " +TRIM(_cPath)+ ALLTRIM(CABEC->D2_PEDIDO) +".TXT"  , "Corpem")
        endif

        fClose(nHdl)
    ENDIF


    U_XAG0099(.T.)
     

    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
//³ cao anterior.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Return



Static Function AtuSX1()
Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local aDados   := {}
Local nI       := 0
Local nJ       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

aAdd( aDados, {'XAG0098','01','Data Ini','Data Ini','Data Ini','mv_ch1','D',8,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0098','02','Data Fim','Data Fim','Data Fim','mv_ch2','D',8,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
//aAdd( aDados, {'RCORGEN','03','Diretorio Arquivo','Diretorio Arquivo','Diretorio Arquivo','mv_ch3','C',90,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0098','03','Pedido de' ,'Pedido de','Pedido de','mv_ch3','C',6,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0098','04','Pedido ate','Pedido ate','Pedido Ate','mv_ch4','C',6,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0098','05','Armazem de' ,'Armazem de' ,'Armazem de' ,'mv_ch5','C',6,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'XAG0098','06','Armazem ate','Armazem ate','Armazem Ate','mv_ch6','C',6,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )



//
// Atualizando dicionário
//
dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aDados )
	If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

// Atualiza Helps
AtuSX1Hlp()

RestArea( aAreaDic )
RestArea( aArea )

Return NIL

Static Function AtuSX1Hlp()



Return NIL


static function sfbusser(xPedido, xfilial)

Local cMaxSerie := ""

cSer := "PED"

_cQry :=  " SELECT DISTINCT  C9_XSREDI  "
_cQry := _cQry + "FROM " + RETSQLNAME("SC9") + " C9 "
_cQry := _cQry + " WHERE   "//C9.D_E_L_E_T_<> '*' AND  "
_cQry := _cQry + "  C9.C9_PEDIDO =  '"+xPedido+"' "
_cQry := _cQry + " AND C9.C9_FILIAL =  '"+xfilial+"' "
_cQry := _cQry + " AND C9.C9_XSREDI <> ' ' "


//CONOUT(_cQry)

If Select("CABEC1") > 0
    dbSelectArea("CABEC1")                   
    DbCloseArea()
EndIf

//* Cria a Query e da Um Apelido
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"CABEC1",.F.,.T.)


dbSelectArea("CABEC1")
dbGotop()

aSer := {}

WHILE CABEC1->(!EOF() )  
   
    aadd(aSer, CABEC1->C9_XSREDI )
    
    //Captura a maior serie gerada até aqui
    If CABEC1->C9_XSREDI <> 'PED'
        If CABEC1->C9_XSREDI > cMaxSerie 
            cMaxSerie := CABEC1->C9_XSREDI
        Endif 
    Endif
  
    CABEC1->(DBSKIP() ) 
ENDDO

If len(aSer) >= 1 
    cSer := strzero(len(aser),3)
Endif 

/*if len(aSer) == 1
cser := '001'
elseif len(aSer) == 2
cser := '002'
elseif len(aSer) == 3
cser := '003'
elseif len(aSer) == 4
cser := '004'
elseif len(aSer) == 5
cser := '005'
elseif len(aSer) == 6
cser := '006'
elseif len(aSer) == 7
cser := '007'
elseif len(aSer) == 8
cser := '008'
elseif len(aSer) == 9
cser := '009'
elseif len(aSer) == 10
cser := '010'
endif */

//Serie escolhida tem que ser maior que a Maior serie encontrada
If cMaxSerie <> '' .and. cser <= cMaxSerie
    cSer := SOMA1(cMaxSerie)
Endif 


return cser
