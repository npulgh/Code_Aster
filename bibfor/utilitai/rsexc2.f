      SUBROUTINE RSEXC2(I1,I2,NOMSD,NOMSY,IORDR,CHEXTR,OPTION,IRET)
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (NMAX=10)
      CHARACTER*15 NOMS(NMAX)
      INTEGER NB,IPREC,IRETG
      LOGICAL ALARME
      SAVE NOMS,NB,IPREC,ALARME,IRETG
      INTEGER IORDR
      CHARACTER*(*) NOMSD,NOMSY
      CHARACTER*24 CHEXTR
      CHARACTER*24 VALK
      CHARACTER*16 NOMCMD,OPTION
      CHARACTER*8  CONCEP
      CHARACTER*16 TYPCON
      CHARACTER*7  STATUT
      INTEGER   INUMEX
      INTEGER VALI
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 19/06/2007   AUTEUR LEBOUVIER F.LEBOUVIER 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR   
C (AT YOUR OPTION) ANY LATER VERSION.                                 
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT 
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF          
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU    
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                            
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE   
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,       
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
C      RECUPERATION DU NOM DU CHAMP-GD  CORRESPONDANT A:
C          NOMSD(IORDR,NOMSY).
C      IL S'AGIT D'UN APPEL A RSEXCH COMPLETE PAR DES VERIFICATIONS
C      NOTAMMENT SUR L'EXISTENCE DU CHAMP NOMSY
C      L'UTILISATION LA PLUS COURANTE CONSISTE A UTILISER I1=I2=1
C         DANS CE CAS, SI LE CHAMP NOMSY N'EXISTE PAS, ON EMET UN
C         MESSAGE D'ALARME ET ON NE CALCULE PAS L'OPTION
C      MAIS IL EST POSSIBLE D'EFFECTUER UNE RECHERCHE POUR PLUSIEURS
C      VALEURS DE NOMSY ET DE CONSERVER LA DERNIERE CORRECTE
C      PAR EXEMPLE POUR 3 NOMS SYMBOLIQUES DE CHAMP ON UTILISERA :
C      CALL RSEXC2(1,3,...,NOMSY1,...)
C      CALL RSEXC2(2,3,...,NOMSY2,...)
C      CALL RSEXC2(3,3,...,NOMSY3,...)
C      LA COHERENCE ENTRE LES DIFFERENTS APPELS EST VERIFIEE ET
C      UN EVENTUEL MESSAGE D'ALARME EST PRODUIT PAR LE DERNIER APPEL
C      CE MODULE EST DESTINE A ETRE APPELE PAR UN OPERATEUR
C      PAR EXEMPLE OP0058 AFIN DE PREPARER LES NOMS DE CHAMP-GD
C      AVANT L'APPEL A MECALC
C ----------------------------------------------------------------------
C IN  : I1,I2  : INDICE COURANT, INDICE MAXIMUM
C IN  : NOMSD  : NOM DE LA STRUCTURE "RESULTAT"
C IN  : NOMSY  : NOM SYMBOLIQUE DU CHAMP A CHERCHER.
C IN  : IORDR  : NUMERO D'ORDRE DU CHAMP A CHERCHER.
C OUT : CHEXTR : NOM DU CHAMP EXTRAIT.
C IN  : OPTION : NOM DE L'OPTION
C OUT : IRET   : CODE RETOUR
C ----------------------------------------------------------------------
      IF (I1.EQ.1) THEN
         IPREC=0
         IRETG=10000
      ENDIF
      IF (IPREC.NE.0.AND.NB.NE.I2) THEN
         CALL U2MESG('F','UTILITAI8_11',0,' ',0,0,0,0.D0)
      ENDIF
      IF (IPREC+1.NE.I1) THEN
         CALL U2MESG('F','UTILITAI8_12',0,' ',0,0,0,0.D0)
      ENDIF
      IF (I2.GT.NMAX) THEN
         CALL U2MESG('F','UTILITAI8_13',0,' ',0,0,0,0.D0)
      ENDIF
      IPREC=I1
      IF (IRETG.LE.0) GOTO 20
      NOMS(I1)=NOMSY
      IF (I1.EQ.1) ALARME=.TRUE.
      NB=I2
      CALL RSEXCH(NOMSD,NOMSY,IORDR,CHEXTR,ICODE)
      ALARME=ALARME.AND.ICODE.GT.0
      IF ( ALARME.AND.I1.EQ.I2) THEN
         CALL GETRES(CONCEP,TYPCON,NOMCMD)
         VALK = NOMS(1)
         CALL U2MESG('A+','UTILITAI8_14',1,VALK,0,0,0,0.D0)
         DO 10 J=2,I2
            VALK = NOMS(J)
            CALL U2MESG('A+','UTILITAI8_15',1,VALK,0,0,0,0.D0)
   10    CONTINUE
         VALI = IORDR
         VALK = OPTION
         CALL U2MESG('A','UTILITAI8_16',1,VALK,1,VALI,0,0.D0)
      ENDIF
      IRETG=MIN(ICODE,IRETG)
   20 CONTINUE
      IRET=IRETG
      END
