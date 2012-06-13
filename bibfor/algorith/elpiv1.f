      SUBROUTINE ELPIV1(XJVMAX,INDIC ,NBLIAC,AJLIAI,SPLIAI,
     &                  SPAVAN,NOMA  ,DEFICO,RESOCO)
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8  NOMA
      CHARACTER*24 RESOCO,DEFICO
      REAL*8       XJVMAX
      INTEGER      NBLIAC
      INTEGER      INDIC
      INTEGER      AJLIAI,SPLIAI
      INTEGER      SPAVAN
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES - UTILITAIRE)
C
C ELIMINATION DES PIVOTS NULS DANS LA MATRICE DE CONTACT
C
C ----------------------------------------------------------------------
C
C
C IN  XJVMAX : VALEUR DU PIVOT MAX
C OUT INDIC  : +1 ON A RAJOUTE UNE LIAISON
C              -1 ON A ENLEVE UNE LIAISON
C I/O NBLIAC : NOMBRE DE LIAISONS ACTIVES
C I/O AJLIAI : INDICE DANS LA LISTE DES LIAISONS ACTIVES DE LA DERNIERE
C              LIAISON CORRECTE DU CALCUL
C              DE LA MATRICE DE CONTACT ACM1AT
C I/O SPLIAI : INDICE DANS LA LISTE DES LIAISONS ACTIVES DE LA DERNIERE
C              LIAISON AYANT ETE CALCULEE POUR LE VECTEUR CM1A
C IN  SPAVAN : INDICE DE DEBUT DE TRAITEMENT DES LIAISONS
C IN  NOMA   : NOM DU MAILLAGE
C IN  DEFICO : SD DE DEFINITION DU CONTACT (ISSUE D'AFFE_CHAR_MECA)
C IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C                'E': RESOCO(1:14)//'.LIAC'
C                'E': RESOCO(1:14)//'.LIOT'
C
C
C
C
C
      CHARACTER*1  TYPESP
      CHARACTER*2  TYPEC0    
      CHARACTER*19 LIAC, LIOT, MACONT, STOC,OUVERT
      INTEGER      JLIAC,JLIOT,JVALE,JVA,JOUV
      INTEGER      CFDISD,NBBLOC,NBLIAI
      REAL*8       COPMAX
      INTEGER      KK1,KK2,KK1F,KK2F,LLF,LLF1,LLF2
      INTEGER      NBOTE,LLIAC
      INTEGER      IBLC
      INTEGER      NIV,IFM
      INTEGER      BLOC,DERCOL
      INTEGER      JSCIB,JSCBL,JSCDE
      LOGICAL      PIVNUL
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('CONTACT',IFM,NIV) 
C 
C --- LECTURE DES STRUCTURES DE DONNEES
C 
      LIAC   = RESOCO(1:14)//'.LIAC'
      LIOT   = RESOCO(1:14)//'.LIOT'
      MACONT = RESOCO(1:14)//'.MATC'
      STOC   = RESOCO(1:14)//'.SLCS'
      CALL JEVEUO(LIAC,'E',JLIAC)
      CALL JEVEUO(LIOT,'E',JLIOT)
      CALL JEVEUO(STOC//'.SCIB','L',JSCIB)
      CALL JEVEUO(STOC//'.SCBL','L',JSCBL)
      CALL JEVEUO(STOC//'.SCDE','L',JSCDE)
C 
C --- INITIALISATIONS
C 
      NBLIAI = CFDISD(RESOCO,'NBLIAI')
      TYPESP = 'S'
      TYPEC0 = 'C0'
      COPMAX = XJVMAX * 1.0D-08
      PIVNUL = .FALSE.
      LLF    = 0
      LLF1   = 0
      LLF2   = 0
      NBBLOC = ZI(JSCDE-1+3)
C
C --- BLOC EN LECTURE
C
      OUVERT = '&&ELPIV2.TRAV'
      CALL WKVECT(OUVERT,'V V L',NBBLOC,JOUV)
C
C --- DETECTION DES PIVOTS NULS
C
      DO 10 KK1 = SPAVAN+1,NBLIAC
        DO 20 KK2 = 1,NBLIAC
          IF (KK2.GT.KK1) THEN
            KK1F = KK2
            KK2F = KK1
          ELSE
            KK1F = KK1
            KK2F = KK2
          ENDIF
          IBLC   = ZI(JSCIB-1+KK1F)
          DERCOL = ZI(JSCBL+IBLC-1)
          BLOC   = DERCOL*(DERCOL+1)/2
C
C ------- ON ACCEDE AU BLOC 
C          
          IF (.NOT.ZL(JOUV-1+IBLC)) THEN
            IF ((IBLC.GT.1).AND.(KK1F.NE.(SPAVAN+1))) THEN
              CALL JELIBE(JEXNUM(MACONT//'.UALF',(IBLC-1)))
              ZL(JOUV-2+IBLC) = .FALSE.
            ENDIF
            CALL JEVEUO (JEXNUM(MACONT//'.UALF',IBLC),'E',JVALE)
            ZL(JOUV-1+IBLC) = .TRUE.
          ENDIF
C
C ------- ACCES A LA DIAGONALE
C          
          JVA    = JVALE-1+(KK1F-1)*(KK1F)/2-BLOC+KK2F
C
C ------- PIVOT NUL ?
C
          IF (ABS(ZR(JVA)).LT.COPMAX) THEN
            PIVNUL = .TRUE.
          ELSE
            PIVNUL = .FALSE.
            GOTO 10
          ENDIF
 20     CONTINUE
C
C ----- ON SUPPRIME LA LIAISON
C
        IF (PIVNUL) THEN
          LLIAC = ZI(JLIAC-1+KK1)
          ZI(JLIOT+4*NBLIAI) = ZI(JLIOT+4*NBLIAI) + 1
          NBOTE              = ZI(JLIOT+4*NBLIAI)
          ZI(JLIOT-1+NBOTE)  = ZI(JLIAC-1+KK1)
          CALL CFTABL(INDIC ,NBLIAC,AJLIAI,SPLIAI,LLF   ,
     &                LLF1  ,LLF2  ,RESOCO,TYPESP,KK1   ,
     &                LLIAC ,TYPEC0)
          CALL CFIMP2(DEFICO,RESOCO,NOMA  ,LLIAC ,TYPEC0,
     &                'PIV')
          GOTO 40
        ENDIF
 10   CONTINUE
C
40    CONTINUE
      CALL JEDETR(OUVERT)
      CALL JEDEMA()
C
      END
