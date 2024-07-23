#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} CNossoNum
//Funções estavam em fontes excluidos AGR094 E AGR003
@author Spiller
@since 28/11/2019
@version undefined
@param aEmpDePara, array, descricao
@type function
/*/    

User Function CNossoNum()
*****************************
Local cDigito 	:= space(01)  
Local _cBanco   := ""
Local _cAgencia := ""
Local _cConta   := ""	

dbSelectArea('SE1')
If Empty(SE1->E1_NUMBCO)
/*  nNossoNum := Val(NossoNum())
   APMSGINFO(nNossoNum)
   cDigito   := CDigitoNosso() 
   nNossoNum := StrZero(nNossoNum,11)+cDigito       

   APMSGINFO(nNossoNum)
	APMSGINFO(cDigito)   
   
   RecLock('SE1',.f.)
   SE1->E1_NUMBCO := nNossoNum
   MsUnlock('SE1') */
   
//******************ALTERADO
	dbSelectArea("SEE")
	DbSetOrder(1)
	if alltrim(funname()) == "FINA150"
		DbSeek(xFilial("SEE")+MV_PAR05+MV_PAR06+MV_PAR07+MV_PAR08) // RIBAS - 26/02/2016 DbSeek(xFilial("SEE")+MV_PAR13+MV_PAR14+MV_PAR15+MV_PAR16)
		_cBanco   := MV_PAR05
   		_cAgencia := MV_PAR06
   		_cConta   := MV_PAR07
	else
		DbSeek(xFilial("SEE")+MV_PAR13+MV_PAR14+MV_PAR15+MV_PAR16) 
		_cBanco   := MV_PAR13
   		_cAgencia := MV_PAR14
   		_cConta   := MV_PAR15	
	endif   
	
	//Valida se t?posicionado no Parâmetro Bancario correto
	IF  alltrim(SEE->EE_CONTA) <>  alltrim(_cConta) .or. alltrim(SEE->EE_AGENCIA) <> alltrim(_cAgencia) 
		Alert(' Entre em contat com a TI - Erro Parâmetros bancários incorretos! ')
		Return
	Endif 
	
	nNossoNum := Right(Alltrim(SEE->EE_FAXATU),11)

// Garante que o numero tera 11 digitos

	If Len(Alltrim(nNossoNum)) <> 11
	     nNossoNum := Strzero(Val(nNossoNum),11)
	Endif     
	
	//Spiller Estava causando duplicidade de NN
	nNossoNum := Strzero(Val(nNossoNum) + 1,11) 

	// Verifica se nao estourou o contador, se estourou reinicializa
	// e grava o proximo numero
	dbSelectArea("SEE")
	RecLock("SEE",.F.)
	If nNossoNum == "99999999999"
	     Replace EE_FAXATU With "00000000001"
	Else
	     _nFaxAtu := Val(nNossoNum)// + 1
	     _nFaxAtu := Strzero(_nFaxAtu,12)
	     Replace EE_FAXATU With _nFaxAtu
	Endif
	SEE->(MsUnlock())


	nNossoNum := val(nNossoNum)
	cDigito   := CDigitoNosso() 
	nNossoNum := StrZero(nNossoNum,11)+cDigito       

 
	RecLock('SE1',.F.)
	SE1->E1_NUMBCO := nNossoNum
	SE1->(MsUnlock()) //MsUnlock('SE1') 

//***************************

Else
//   nNossoNum := NossoNum()
   nNossoNum := Alltrim(SE1->E1_NUMBCO)
EndIf


Return nNossoNum 

Static Function CDigitoNosso()
******************************
nCont:=0

nSoma1 := val(subs(alltrim(mv_par17),02,1))*2  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
nSoma2 := val(subs(alltrim(mv_par17),03,1))*7  // Como o campo tem 3 posiçoes no parametro considera as duas ultimas 007 = 07
nSoma3 := val(subs(StrZero(nNossoNum,11),01,1))*6
nSoma4 := val(subs(StrZero(nNossoNum,11),02,1))*5
nSoma5 := val(subs(StrZero(nNossoNum,11),03,1))*4
nSoma6 := val(subs(StrZero(nNossoNum,11),04,1))*3
nSoma7 := val(subs(StrZero(nNossoNum,11),05,1))*2
nSoma8 := val(subs(StrZero(nNossoNum,11),06,1))*7
nSoma9 := val(subs(StrZero(nNossoNum,11),07,1))*6
nSomaA := val(subs(StrZero(nNossoNum,11),08,1))*5
nSomaB := val(subs(StrZero(nNossoNum,11),09,1))*4
nSomaC := val(subs(StrZero(nNossoNum,11),10,1))*3
nSomaD := val(subs(StrZero(nNossoNum,11),11,1))*2

cDigito := mod((nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD),11)

nCont := iif(cDigito == 1, "P", iif(cDigito == 0 , "0", strzero(11-cDigito,1)))
Return nCont



User Function 	XNossoNum()
******************************
Local cDigito 	:= space(01)

dbSelectArea('SE1')
If Empty(SE1->E1_NUMBCO)  

   Conout('AGR094 ANTES: '+SE1->E1_NUM + SE1->E1_PARCELA +' - '+ SEE->EE_CONTA+' - '+SEE->EE_FAXATU)	
   nNossoNum := Val(NossoNum())                         
   Conout('AGR094 DEPOIS: '+SE1->E1_NUM + SE1->E1_PARCELA +' - '+ SEE->EE_CONTA+' - '+SEE->EE_FAXATU)	
   
   cDigito   := XDigitoNosso()
   if Alltrim(SEE->EE_CODEMP) == '2988362'.or. Alltrim(SEE->EE_CODEMP) == '3509616'    
      nNossoNumE1 :=  StrZero(nNossoNum,9)+cDigito
      nNossoNum   :=  Alltrim(SEE->EE_CODEMP) + StrZero(nNossoNum,9)+cDigito      
   else
      nNossoNumE1 := StrZero(nNossoNum,11)+cDigito
      nNossoNum   := StrZero(nNossoNum,11)+cDigito
        
      //VALIDA CONTA VELHA DO BANCO DO BRASIL  SPILLER - 09/072018                 
      /*If cEmpant=='01' 
      	If Substr(nNossoNum,1,6) <> '189343'
          	Alert('ERRO DE NN, ENTRE EM CONTATO COM A TI E N? ENVIE O BOLETO PARA O CLIENTE!')
     	 Endif
   	  Endif	*/
   endif     
    
   Conout('AGR094 NN('+ nNossoNum +'): '+ SE1->E1_NUM + SE1->E1_PARCELA +' - '+ SEE->EE_CONTA+' - '+SEE->EE_FAXATU)
      
   RecLock('SE1',.f.)
   SE1->E1_NUMBCO := nNossoNumE1
   SE1->(MsUnlock())//'SE1')
Else
//	nNossoNum := NossoNum()
   if Alltrim(SEE->EE_CODEMP) == '2988362' .or. Alltrim(SEE->EE_CODEMP) == '3509616'     
      nNossoNum := Alltrim(SEE->EE_CODEMP) + Alltrim(SE1->E1_NUMBCO)
   else
      nNossoNum := Alltrim(SE1->E1_NUMBCO)
      //VALIDA CONTA VELHA DO BANCO DO BRASIL SPILLER - 09/072018                  
      /*If cEmpant=='01' 
      	If Substr(nNossoNum,1,6) <> '189343' 
          	Alert('ERRO DE NN, ENTRE EM CONTATO COM A TI E N? ENVIE O BOLETO PARA O CLIENTE!')
     	 Endif
   	  Endif	 */     
   endif      
EndIf


Return nNossoNum 

Static Function XDigitoNosso()
******************************
nCont:=0                                            

if Alltrim(SEE->EE_CODEMP) == '2988362'
   nSoma1 := 0 //val(subs(alltrim(mv_par17),01,1))*2
   nSoma2 := 0 //val(subs(alltrim(mv_par17),02,1))*7
   nSoma3 := val(subs(StrZero(nNossoNum,9),01,1))*7
   nSoma4 := val(subs(StrZero(nNossoNum,9),02,1))*8
   nSoma5 := val(subs(StrZero(nNossoNum,9),03,1))*9
   nSoma6 := val(subs(StrZero(nNossoNum,9),04,1))*2
   nSoma7 := val(subs(StrZero(nNossoNum,9),05,1))*3
   nSoma8 := val(subs(StrZero(nNossoNum,9),06,1))*4
   nSoma9 := val(subs(StrZero(nNossoNum,9),07,1))*5
   nSomaA := val(subs(StrZero(nNossoNum,9),08,1))*6
   nSomaB := val(subs(StrZero(nNossoNum,9),09,1))*7

    cDigito := mod(nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
    nSoma8+nSoma9+nSomaA+nSomaB,9)
Else 
   nSoma1 := 0 //val(subs(alltrim(mv_par17),01,1))*2
   nSoma2 := 0 //val(subs(alltrim(mv_par17),02,1))*7
   nSoma3 := val(subs(StrZero(nNossoNum,11),01,1))*7
   nSoma4 := val(subs(StrZero(nNossoNum,11),02,1))*8
   nSoma5 := val(subs(StrZero(nNossoNum,11),03,1))*9
   nSoma6 := val(subs(StrZero(nNossoNum,11),04,1))*2
   nSoma7 := val(subs(StrZero(nNossoNum,11),05,1))*3
   nSoma8 := val(subs(StrZero(nNossoNum,11),06,1))*4
   nSoma9 := val(subs(StrZero(nNossoNum,11),07,1))*5
   nSomaA := val(subs(StrZero(nNossoNum,11),08,1))*6
   nSomaB := val(subs(StrZero(nNossoNum,11),09,1))*7
   nSomaC := val(subs(StrZero(nNossoNum,11),10,1))*8
   nSomaD := val(subs(StrZero(nNossoNum,11),11,1))*9

    cDigito := mod(nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
    nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD,11)
EndIf

//cDigito := mod(nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
//nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD,11)

//nCont := iif(cDigito == 10, "X", iif(cDigito == 0 , "0", strzero(11-cDigito,1)))
nCont := iif(cDigito == 10, "X", iif(cDigito == 0 , "0", strzero(cDigito,1)))
Return nCont
