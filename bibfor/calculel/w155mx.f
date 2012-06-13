      SUBROUTINE W155MX(NOMRES,RESU,NBORDR,LIORDR)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C RESPONSABLE PELLET J.PELLET
C ======================================================================
C     COMMANDE :  POST_CHAMP / MIN_MAX_SP
C ----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8 NOMRES,RESU
      INTEGER NBORDR,LIORDR(NBORDR)
C
      INTEGER IFM,NIV
      INTEGER IRET,I,NUORDR,IBID,NOCC,IOCC,NCHOUT
      CHARACTER*8 MODELE,CARELE,MATE
      CHARACTER*8 MODEAV,NOCMP,TYMAXI
      CHARACTER*4 TYCH
      CHARACTER*16 MOTFAC,NOMSYM,NOMSY2
      CHARACTER*19 CHIN,CHEXTR,EXCIT,LIGREL,RESU19
      CHARACTER*24 NOMPAR
      INTEGER      IARG
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C

      CALL INFMAJ()
      CALL INFNIV(IFM,NIV)
      RESU19=RESU



C     -- 1. : Y-A-T-IL QUELQUE CHOSE A FAIRE ?
C     ----------------------------------------
      CALL GETFAC('MIN_MAX_SP',NOCC)
      IF (NOCC.EQ.0)GOTO 30
      CALL ASSERT(NOCC.LT.10)


      DO 20,IOCC=1,NOCC

C     -- 2.  : NOMSYM, NOCMP, TYMAXI, TYCH :
C     --------------------------------------------------
        MOTFAC='MIN_MAX_SP'
        CALL GETVTX(MOTFAC,'NOM_CHAM',IOCC,IARG,1,NOMSYM,IBID)
        CALL GETVTX(MOTFAC,'NOM_CMP',IOCC,IARG,1,NOCMP,IBID)
        CALL GETVTX(MOTFAC,'TYPE_MAXI',IOCC,IARG,1,TYMAXI,IBID)
        TYCH=NOMSYM(6:9)
        CALL ASSERT(TYCH.EQ.'ELNO' .OR. TYCH.EQ.'ELGA')


C     -- 3. : BOUCLE SUR LES CHAMPS
C     --------------------------------------------------
        MODEAV=' '
        DO 10,I=1,NBORDR
          NUORDR=LIORDR(I)
          CALL RSEXCH(RESU19,NOMSYM,NUORDR,CHIN,IRET)
          IF (IRET.EQ.0) THEN

C         -- 3.1 : MODELE, CARELE, LIGREL :
            CALL RSLESD(RESU,NUORDR,MODELE,MATE,CARELE,EXCIT,IBID)
            IF (MODELE.NE.MODEAV) THEN
              CALL EXLIMA(' ',1,'G',MODELE,LIGREL)
              MODEAV=MODELE
            ENDIF

            NOMSY2='UTXX_'//TYCH
        CALL GETVIS(MOTFAC,'NUME_CHAM_RESU',IOCC,IARG,1,NCHOUT,IBID)
        CALL ASSERT(NCHOUT.GE.1 .AND. NCHOUT.LE.20)
            CALL CODENT(NCHOUT,'D0',NOMSY2(3:4))
            IF (TYCH.EQ.'ELGA') THEN
              NOMPAR='PGAMIMA'
            ELSEIF (TYCH.EQ.'ELNO') THEN
              NOMPAR='PNOMIMA'
            ELSE
              CALL ASSERT(.FALSE.)
            ENDIF

            CALL RSEXCH(NOMRES,NOMSY2,NUORDR,CHEXTR,IRET)
            CALL ASSERT(IRET.EQ.100)
            CALL ALCHML(LIGREL,'MINMAX_SP',NOMPAR,'G',CHEXTR,IRET,' ')
            CALL ASSERT(IRET.EQ.0)
            CALL W155M2(CHIN,CARELE,LIGREL,CHEXTR,NOMSYM,NOCMP,TYMAXI)
            CALL RSNOCH(NOMRES,NOMSY2,NUORDR,' ')
          ENDIF
   10   CONTINUE
   20 CONTINUE


   30 CONTINUE
      CALL JEDEMA()
      END
