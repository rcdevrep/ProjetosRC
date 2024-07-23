#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XAG0065
//Função para gravação dos Campos de Substituição tributaria para tabelas da SFT 
@author Leandro Spiller
@since 11/02/2020
@version 1
@param null
@type function
/*/
User Function XAG0065()

    Local cProduto    := ""
    Local cQuery      := ""
    //Local cAtualiza   := ""
    Local nD1_BASNDES := 0 
    Local nD1_ALQNDES := 0
    Local nD1_ICMNDES := 0
    Local nCalcSFT    := 0  
    Local cPerg       := "XAG0065"

    iF !(Pergunte(cPerg,.T.))
        Return
    Endif

    //Se não preencheu nenhum parametro, retorna
    If Empty(MV_PAR01) .AND. Empty(MV_PAR02) .AND. Empty(MV_PAR03)
        Alert('Obrigatório o Preenchimento de pelo menos 1 parâmetro')
        Return
    Endif

    cQuery := " SELECT FT.R_E_C_N_O_, FT_NFISCAL,FT_PRODUTO,FT_VSTANT,FT_PSTANT,FT_BSTANT,D2_TOTAL,D2_ALIQSOL,D2_QUANT FROM SFT010(NOLOCK) FT "
    cQuery += " INNER JOIN SD2010(NOLOCK) D2 ON D2_DOC = FT_NFISCAL AND D2_FILIAL = FT_FILIAL AND "
    cQuery += " D2.D_E_L_E_T_ = '' AND D2_SERIE = FT_SERIE AND SUBSTRING(D2_CLASFIS,2,2) = '60' AND D2_ITEM = FT_ITEM "
    cQuery += " AND FT_PRODUTO = D2_COD AND D2_TIPO = 'N' "
    cQuery += " WHERE FT_FILIAL = '06' "
    cQuery += " AND FT.D_E_L_E_T_ = ''  AND FT_TIPOMOV = 'S'  AND FT_FILIAL = '06' "
    cQuery += " AND ( FT_VSTANT = 0 OR FT_PSTANT = 0 OR FT_BSTANT = 0) "

    If !Empty(MV_PAR01)
        cQuery += "  AND FT_NFISCAL ='"+alltrim(MV_PAR01)+"' "
    Endif
    If !Empty(MV_PAR02)
        cQuery += "  AND FT_SERIE ='"+alltrim(MV_PAR02)+"' "
    Endif 
    If !Empty(MV_PAR03)
        cQuery += " AND FT_EMISSAO = '"+dtos(MV_PAR03)+"' "
    Endif
    If !Empty(MV_PAR04)
        cQuery += " AND FT_PRODUTO = '"+(MV_PAR04)+"' "
    Endif

    cQuery += " AND FT_CHVNFE = '' "
       
    cQuery += " ORDER BY FT_PRODUTO " 

    conout(cQuery)
	If Select('FT0065') <> 0 
		dbSelectArea('FT0065')
		FT0065->(dbCloseArea())
	Endif 
	
	TCQuery cQuery NEW ALIAS 'FT0065' 

    WHILE FT0065->(!eof())

        //*****************************************************// 
        // 1) Se tem duas informações na SFT Não vai até a SD1
        //*****************************************************// 
        //Se tem Valor e Aliquota Preenche a base 
        If FT0065->FT_VSTANT > 0 .AND.  FT0065->FT_PSTANT > 0 

            nCalcSFT := Round( ( FT0065->FT_VSTANT / FT0065->FT_PSTANT) * 100, 2 )
            cUpdSFT := " UPDATE SFT010 SET " 
            cUpdSFT += " FT_BSTANT  =  "+Alltrim(Str(nCalcSFT))+" "
            cUpdSFT += " WHERE R_E_C_N_O_ = "+ALLTRIM(STR(FT0065->R_E_C_N_O_))+" AND D_E_L_E_T_ = '' " 
        
        ElseIf FT0065->FT_BSTANT > 0 .AND.  FT0065->FT_PSTANT > 0 //Se tem BASE e Aliquota Preenche valor 

            nCalcSFT := Round(FT0065->FT_BSTANT * (FT0065->FT_PSTANT / 100 ),2 )
            cUpdSFT := " UPDATE SFT010 SET " 
            cUpdSFT += " FT_VSTANT = "+Alltrim(Str(nCalcSFT))+" "
            cUpdSFT += " WHERE R_E_C_N_O_ = "+ALLTRIM(STR(FT0065->R_E_C_N_O_))+" AND D_E_L_E_T_ = '' " 

        Else //Se tem BASE e valor Preenche a aliquota 

            nCalcSFT := Round((  (FT0065->FT_VSTANT / FT0065->FT_BSTANT ) * 100 ),2)
            cUpdSFT := " UPDATE SFT010 SET " 
            cUpdSFT += " FT_PSTANT  = "+Alltrim(Str(nCalcSFT))+" "    
            cUpdSFT += " WHERE R_E_C_N_O_ = "+ALLTRIM(STR(FT0065->R_E_C_N_O_))+" AND D_E_L_E_T_ = '' " 
        Endif

        //Se Calculou valores na SFT  realiza Update e sai
        If nCalcSFT >0 
            
            If (TCSQLExec(cUpdSFT) < 0)
              Return MsgStop("TCSQLError() " + TCSQLError())
            EndIf
            
            FT0065->(dbskip()) 
            Loop 

        Endif 

        //***************************************//      
        // 2) Vai até a SD1 para gravar os dados //
        //***************************************//
        //Se ja preencheu o Produto Ignora
        If cProduto  == FT0065->FT_PRODUTO
            FT0065->(dbskip()) 
            Loop 
        Endif

        cProduto :=  FT0065->FT_PRODUTO

        //Busca Recno  da Ultima Nota 
        cQuery := " SELECT TOP 1 R_E_C_N_O_
        cQuery += " ,D1_TOTAL AS XD1_BASNDES,D1_ALIQSOL AS XD1_ALQNDES,ROUND(D1_TOTAL * (D1_ALIQSOL /100) ,2) AS XD1_ICMNDES"
        cQuery += " ,D1_BASNDES,D1_ALQNDES,D1_ICMNDES,D1_QUANT "
        cQuery += " FROM SD1010(NOLOCK) "
        cQuery += " WHERE D1_COD = '"+cProduto+"' "// --Preencher produto
        cQuery += " AND D1_FILIAL = '06' " //--Preencher a filial
        cQuery += " AND D1_TIPO = 'N' "
        cQuery += " AND D_E_L_E_T_ = '' " 
        cQuery += " ORDER BY D1_DTDIGIT DESC  "

        conout(cQuery)
        If Select('XAG0065') <> 0 
            dbSelectArea('XAG0065')
            XAG0065->(dbCloseArea())
        Endif 
        
        TCQuery cQuery NEW ALIAS 'XAG0065' 

        //Atualiza Campos da SD1
        If XAG0065->(!EOF())

            //cQuery := " SELECT TOP 1 R_E_C_N_O_,D1_BASNDES,D1_ALQNDES,D1_ICMNDES FROM SD1010(NOLOCK) "

            //Se não estiver preenchido na SD1, preenche 
            If XAG0065->D1_BASNDES == 0 .AND. XAG0065->D1_ALQNDES == 0 .AND. XAG0065->D1_ICMNDES == 0 
            
                //Atualiza SD1 pelo Recno da ultima nota
                cUpdSD1 := " UPDATE SD1010 SET 
                cUpdSD1 += " D1_BASNDES =  D1_TOTAL, 
                cUpdSD1 += " D1_ALQNDES =  D1_ALIQSOL,
                cUpdSD1 += " D1_ICMNDES =  ROUND((D1_TOTAL * ( D1_ALIQSOL/100)),2)
                cUpdSD1 += " ,D1_ORIIMP  =  'ICMSST' "
                cUpdSD1 += " WHERE R_E_C_N_O_ = "+Alltrim(str(XAG0065->R_E_C_N_O_))+""//
                cUpdSD1 += " AND D1_FILIAL = '06' " //--Preencher a filial
                cUpdSD1 += " AND D1_TIPO = 'N' "
                cUpdSD1 += " AND D_E_L_E_T_ = '' " 

                nD1_BASNDES := XAG0065->xD1_BASNDES
                nD1_ALQNDES := XAG0065->xD1_ALQNDES
                nD1_ICMNDES := XAG0065->xD1_ICMNDES 
                
                conout(cUpdSD1)
            
                If (TCSQLExec(cUpdSD1) < 0)
                   Return MsgStop("TCSQLError() " + TCSQLError())
                EndIf
            Else
                nD1_BASNDES := XAG0065->D1_BASNDES
                nD1_ALQNDES := XAG0065->D1_ALQNDES
                nD1_ICMNDES := XAG0065->D1_ICMNDES 
            Endif

            nD1_BASNDES := Round( (nD1_BASNDES / XAG0065->D1_QUANT) * FT0065->D2_QUANT , 2)
            nD1_ICMNDES := Round(  (nD1_ICMNDES / XAG0065->D1_QUANT) * FT0065->D2_QUANT , 2)


            //Atualiza a SFT
            cUpdSFT := " UPDATE SFT010 SET " 
            cUpdSFT += " FT_BSTANT  =  "+Alltrim(Str(nD1_BASNDES))+", "
            cUpdSFT += " FT_PSTANT  = "+Alltrim(Str(nD1_ALQNDES))+", "
            cUpdSFT += " FT_VSTANT = "+Alltrim(Str(nD1_ICMNDES))+" "
            cUpdSFT += "WHERE R_E_C_N_O_ = "+ALLTRIM(STR(FT0065->R_E_C_N_O_))+" AND D_E_L_E_T_ = '' " 


            //cAtualiza += +"(" + FT0065->FT_NFISCAL + " - " + FT0065->FT_PRODUTO + ") - " 
            conout(cUpdSFT)
            If (TCSQLExec(cUpdSFT) < 0)
                Return MsgStop("TCSQLError() " + TCSQLError())
            EndIf 
        Else
           
            nAliqSol := iif (FT0065->D2_ALIQSOL >0 , FT0065->D2_ALIQSOL, 17) 
             
            //Atualiza a SFT
            cUpdSFT := " UPDATE SFT010 SET " 
            cUpdSFT += " FT_BSTANT  =  "+Alltrim(Str(FT0065->D2_TOTAL))+", "
            cUpdSFT += " FT_PSTANT  = "+Alltrim(Str(FT0065->D2_ALIQSOL))+", "
            cUpdSFT += " FT_VSTANT = "+Alltrim(Str(Round(FT0065->D2_TOTAL * (nAliqSol / 100),2 ) ))+" "
            cUpdSFT += "WHERE R_E_C_N_O_ = "+ALLTRIM(STR(FT0065->R_E_C_N_O_))+" AND D_E_L_E_T_ = '' " 

            //cAtualiza += +"(" + FT0065->FT_NFISCAL + " - " + FT0065->FT_PRODUTO + ") - " 
            conout(cUpdSFT)

            If (TCSQLExec(cUpdSFT) < 0)
                Return MsgStop("TCSQLError() " + TCSQLError())
            EndIf 

        Endif

        conout(' ')
        conout('-------------------------------------------------')
        conout(' ')
        FT0065->(dbSkip())
    Enddo


Return
