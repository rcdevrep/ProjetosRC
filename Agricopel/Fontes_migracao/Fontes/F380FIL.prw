	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF380FIL   บAutor  ณMicrosiga           บ Data ณ  11/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtro para desconsiderar cheques avulsos e cheques de pgtoบฑฑ
ฑฑบ          ณ na reconciliacao manual.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function F380FIL() 
    // Primeira situacao trata-se de cheque troco      DH, CA, CH Sao os Tipo para Cheques Troco/Avulso/Talao no Sistema!!!!!!
    // Segunda  situacao trata-se de lancamentos e baixas diversas que nao sejam cheques e cheques troco
    // Terceira situacao trata-se de lancamentos de cheques talao diversos para outros bancos pela cecilia tesouraria quem nao sao reconciliados pelo arquivo BRADESCO (237)
    // Quarta   situacao trata-se de lancamentos movimento bancario M1
    //
    // Qdo ARQCNAB trata-se de cheque troco compensado, e MOEDA igual M1 trata-se de Movimento Bancario digitado
    //      
    // Na primeira situa็ao o sistema somente traz registros que nao sejam cheque troco e que estejam com ARQCNAB e nao tem x na E5_RECONC (Podem ter sido cancelada reconcilia็ao motivo cancelamento de baixa e agora se faz novamente)
    // Na segunda situa็ao o sistema somente traz registros que nao sejam cheque troco e que estejam com ARQCNAB e nao tem x na E5_RECONC vindos de baixas diversas feitas manualmente!!
    // Na terceira situa็ao o sistema traz somente registros de cheques talao que nao sejam do BRADESCO pois este tem reconcilia็ao pelo ARQCNAB vindo do banco no arquivo e feita a reconconcilia็ao automatica pelo arquivo Bradesco!!.
    // Na quarta situa็ao o sistema traz somente registros de movimenta็ao bancaria feita manualmente onde M1 fica gravado na moeda indicando isto!
    
    // Na Versao Microsiga Protheus 10 o filtro abaixo com  <> '' ou == '' nao funciona mais, substituido por !Empty ou Empty - Deco 10/01/2008
    // Tambem invertido cfe abaixo " por ' para deixar no padrao dos demais filtros (F240FIL, FA460FIL, F281FIL) pois tambem pode ocorrer problemas no Protheus 10 - Deco 10/01/2008
    
    //Spiller - Teste se a usuแria estแ utilizando o ambiente correto
    Local _cAmb    := GetEnvServer()
    If ("CUSTOM" $ Upper(_cAmb)) .AND. cEmpAnt == '01'
        Final('** ERRO **', 'Erro F380FIL.PRW, Favor entrar em contato com a TI! ', .F.)
    Endif

	cRet := Space(350)
//	cRet := "((E5_TIPODOC <> 'DH' .AND. E5_TIPODOC <> 'CA' .AND. E5_TIPODOC <> 'CH' .AND. E5_ARQCNAB <> '') .OR. (E5_TIPODOC <> 'DH' .AND. E5_TIPODOC <> 'CH' .AND. E5_ARQCNAB == '') .OR. (E5_BANCO <> '237' .AND. SUBSTR(E5_HISTOR,1,5) == 'TALAO' .AND. E5_ARQCNAB == '') .OR. E5_MOEDA == 'M1')"
	
    //Roda filtro apenas no N2SD9W
    If !("CUSTOM" $ Upper(_cAmb)) 
        cRet := '((E5_TIPODOC <> "DH" .AND. E5_TIPODOC <> "CA" .AND. E5_TIPODOC <> "CH" .AND. !Empty(E5_ARQCNAB) ) .OR. (E5_TIPODOC <> "DH" .AND. E5_TIPODOC <> "CA" .AND. E5_TIPODOC <> "CH" .AND. Empty(E5_ARQCNAB) ) .OR. (E5_BANCO <> "237" .AND. SUBSTR(E5_HISTOR,1,5) == "TALAO" .AND. Empty(E5_ARQCNAB) ) .OR. E5_MOEDA == "M1")'
    Endif
Return cRet