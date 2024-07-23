#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"					 
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ XAG0052 ¦  Autor ¦ Osmar Schimitberger¦ Data   ¦ 15/05/2019¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦  Rotina LP 650-001 p/tratar valor da Contabilizacao        ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Agricopel - Chamado 57063 - ICMS ST SOMENTE DESTACAR       ¦¦¦
¦¦¦          ¦ NA ENTRADA DA NOTA     				                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function XAG0052

   Local nValor:= 0
   Local _aArea:= GetArea()

   If ((SM0->M0_CODIGO == "01") .or. (SM0->M0_CODIGO == "15"))  //Chamado 57063 - ICMS ST SOMENTE DESTACAR NA ENTRADA DA NOTA

      nValor:= IIF(!(SD1->D1_TIPO $ "D/I").AND.SD1->D1_RATEIO<>"1".AND.!(SD1->D1_TES$"286/248/239/241").AND.!SUBS(SD1->D1_CF,2,3)$"415/910/151/152/557/659/409",IIF(SF4->F4_INCSOL="S",SD1->(D1_TOTAL+D1_VALIPI+D1_ICMSRET-D1_VALDESC+D1_DESPESA+D1_VALFRE),SD1->(D1_TOTAL+D1_VALIPI-D1_VALDESC+D1_DESPESA+D1_VALFRE)),0)

      if (alltrim(SD1->D1_CF)$"1902/2902/1903/2903/1908/2908/1909/2909/1915/2915/1916/2916/1904/2904/1905/2905") //Chamado 417048 nao contabilizar cf 1902/2002 / Chamado 417048 nao contabilizar cf 1903/2903 

         nValor:= 0

      Endif

   ElseIf ((SM0->M0_CODIGO == "20") .or. (SM0->M0_CODIGO == "21") .or. (SM0->M0_CODIGO == "51")) //Chamado 57063 - ICMS ST SOMENTE DESTACAR NA ENTRADA DA NOTA

      nValor:= IIF((SD1->D1_TIPO<>"D".AND. SD1->D1_RATEIO<>"1".AND.!(SUBS(SD1->D1_CF,2,3)$"917/113/113/910/604")),IIF(SF4->F4_INCSOL="S",SD1->D1_TOTAL+SD1->D1_VALFRE+SD1->D1_ICMSRET-SD1->D1_VALDESC,SD1->D1_TOTAL+SD1->D1_VALFRE-SD1->D1_VALDESC),0)

   Endif


   RestArea(_aArea)

Return(nValor)


User Function XAG0052A()

   Local _nValor     := 0
   Local _aArea     := GetArea()
   Local _cAliasQry := GetNextAlias()
   Local _cQuery    := ""
   
   _cQuery += " SELECT SUM(CDA_VALOR)  AS VALOR FROM "+RetSqlName('CDA')+" (NOLOCK) CDA "
   _cQuery += " WHERE CDA_FILIAL = '"+SD1->D1_FILIAL +"' "
   _cQuery += " AND CDA_NUMERO = '"+ SD1->D1_DOC + "' "
   _cQuery += " AND CDA_SERIE  = '"+ SD1->D1_SERIE + "' "
   _cQuery += " AND CDA_CLIFOR  = '"+ SD1->D1_FORNECE + "' "
   _cQuery += " AND CDA_LOJA  = '"+ SD1->D1_LOJA + "' "
   _cQuery += " AND CDA_NUMITE  = '"+ SD1->D1_ITEM  + "' "
   _cQuery += " AND CDA.D_E_L_E_T_ = '' "

   If Select(_cAliasQry) <> 0
      dbSelectArea(_cAliasQry)
      (_cAliasQry)->(dbCloseArea())
   Endif
                    
   TCQuery _cQuery NEW ALIAS (_cAliasQry)

   IF  (_cAliasQry)->(!eof())
      _nValor := (_cAliasQry)->VALOR
   Endif 

   IF SD1->D1_RATEIO=="1"
      _nValor := ROUND( _nValor * (SDE->DE_PERC / 100),2 )
   ENDIF
   
   (_cAliasQry)->(dbCloseArea())

   RestArea(_aArea)

Return(_nValor)
