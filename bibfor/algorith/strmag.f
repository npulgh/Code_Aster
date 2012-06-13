      SUBROUTINE  STRMAG (NUGENE,TYPROF)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C***********************************************************************
C    P. RICHARD     DATE 02/11/92
C-----------------------------------------------------------------------
C  BUT:      < REFE 127 >
      IMPLICIT REAL*8 (A-H,O-Z)

C  CREER LE STOCKAGE DU NUME_DDL_GENE
C-----------------------------------------------------------------------

C NUGENE   /I/: NOM K14 DU NUME_DDL_GENE


      INCLUDE 'jeveux.h'
      REAL*8           JEVTBL
      REAL*8 VALR(2)



      CHARACTER*8 NOMPRN,MODGEN,SST(2)
      CHARACTER*19 STOMOR,STOLCI,PRGENE
      CHARACTER*14 NUGENE
      CHARACTER*8 BID
      CHARACTER*24 TYPROF
      CHARACTER*1 K1BID

C-----------------------------------------------------------------------

      CALL JEMARQ()
      IFIMES=IUNIFI('MESSAGE')
      STOMOR=NUGENE//'.SMOS'
      STOLCI=NUGENE//'.SLCS'
      PRGENE=NUGENE//'.NUME'
      CALL JEVEUO(PRGENE//'.NEQU','L',LLNEQU)
      NEQ=ZI(LLNEQU)


      IF (TYPROF.EQ.'PLEIN' .OR. TYPROF.EQ.'DIAG') THEN
C        CREATION DES STOCKAGES MORSE ET L_CIEL :
         CALL CRSMOS(STOMOR,TYPROF,NEQ)
         RTBLOC=JEVTBL('TAILLE_BLOC')
         CALL SMOSLI(STOMOR,STOLCI,'G',RTBLOC)
         GO TO 9999
      END IF


C     -- CAS TYPROF=LIGN_CIEL :
C     --------------------------
      RTBLOC=JEVTBL('TAILLE_BLOC')
      NTBLOC=INT(1024*RTBLOC)

C----------------RECUPERATION DU MODELE GENERALISE----------------------
C          ET NOMBRE DE SOUS-STRUCTURE
      CALL JEVEUO(PRGENE//'.REFN','L',LLREF)
      MODGEN=ZK24(LLREF)(1:8)
      CALL JELIRA(MODGEN//'      .MODG.SSNO','NOMMAX',NBSST,K1BID)


C---------------DETERMINATION DU PROFIL(LIGNE DE CIEL)------------------
      CALL WKVECT(STOLCI//'.SCHC','G V I',NEQ,JSCHC)

      CALL JEVEUO(PRGENE//'.NUEQ','L',LLNUEQ)
      CALL JELIRA(PRGENE//'.PRNO','NMAXOC',NBPRNO,K1BID)
      IF (TYPROF.EQ.'LIGN_CIEL') THEN

C  BOUCLE SUR LIGRELS DU PRNO
      DO 10 I=1,NBPRNO
        CALL JELIRA(JEXNUM(PRGENE//'.PRNO',I),'LONMAX',NTPRNO,BID)
        NTPRNO=NTPRNO/2
        CALL JENUNO(JEXNUM(PRGENE//'.LILI',I),NOMPRN)

C   CAS DU PRNO &SOUSSTR (MATRICES PROJETEES)
        IF(NOMPRN.EQ.'&SOUSSTR') THEN
          CALL JEVEUO(JEXNUM(PRGENE//'.PRNO',I),'L',LLPRS)
          DO 20 J=1,NTPRNO
            IAD1=ZI(LLPRS+(J-1)*2)
            NBLIG=ZI(LLPRS+(J-1)*2+1)

C   BOUCLE SUR LES COLONNES DE LA MATRICE PROJETEE
            DO 30 K=1,NBLIG
              IADCOU=ZI(LLNUEQ+IAD1-1+K-1)
              LH=JSCHC+IADCOU-1
              ZI(LH)=MAX(ZI(LH),K)
30          CONTINUE
20        CONTINUE


C    CAS  DU PRNO LAGRANGE D'INTERFACE
        ELSE
          CALL JEVEUO(JEXNUM(PRGENE//'.ORIG',I),'L',LLORL)
          CALL JEVEUO(JEXNUM(PRGENE//'.PRNO',I),'L',LLPRL)
          CALL JENONU(JEXNOM(PRGENE//'.LILI','&SOUSSTR'),IBID)
          CALL JEVEUO(JEXNUM(PRGENE//'.ORIG',IBID),'L',LLORS)
          CALL JENONU(JEXNOM(PRGENE//'.LILI','&SOUSSTR'),IBID)
          CALL JEVEUO(JEXNUM(PRGENE//'.PRNO',IBID),'L',LLPRS)

          DO 40 J=1,NTPRNO
            NULIA=ZI(LLORL+J-1)
            CALL  JEVEUO(JEXNUM(MODGEN//'      .MODG.LIDF',NULIA),
     &'L',LLDEFL)
C RECUPERATION DES 2 SOU-STRUCTURES ASSOCIEES
            SST(1)=ZK8(LLDEFL)
            SST(2)=ZK8(LLDEFL+2)
            IAD1L=ZI(LLPRL+(J-1)*2)
            NBLIG=ZI(LLPRL+(J-1)*2+1)
            DO 50 K=1,2
              CALL JENONU(JEXNOM(MODGEN//'      .MODG.SSNO',SST(K)),
     &NUSST)
C  RECUPERATION NUMERO TARDIF
              DO 60 L=1,NBSST
                IF(ZI(LLORS+L-1).EQ.NUSST) NSSTAR=L
60            CONTINUE
              IAD1C=ZI(LLPRS+(NSSTAR-1)*2)
              NBCOL=ZI(LLPRS+(NSSTAR-1)*2+1)
              DO 70 LL=1,NBLIG
                  IADL=ZI(LLNUEQ+(IAD1L-1)+(LL-1))
                DO 80 LC=1,NBCOL
                  IADC=ZI(LLNUEQ+(IAD1C-1)+(LC-1))
                  LH=JSCHC+MAX(IADC,IADL)-1
                  ZI(LH)=MAX(ZI(LH),ABS(IADC-IADL)+1)
80              CONTINUE
70            CONTINUE
50          CONTINUE

C TRAITEMENT DES MATRICES LAGRANGE-LAGRANGE

C RECUPERATION DU NUMERO NOEUD TARDIF ANTAGONISTE
            DO 90 L=1,NTPRNO
              IF(ZI(LLORL+L-1).EQ.NULIA.AND.L.NE.J) NUANT=L
90          CONTINUE
            IAD2L=ZI(LLPRL+(NUANT-1)*2)
            DO 95 LL=1,NBLIG
              IADL=ZI(LLNUEQ+(IAD1L-1)+(LL-1))
              IADC=ZI(LLNUEQ+(IAD2L-1)+(LL-1))
C TERME CROISE LAGRANGE LAGRANGE
              LH=JSCHC+MAX(IADC,IADL)-1
              ZI(LH)=MAX(ZI(LH),ABS(IADC-IADL)+1)
C TERME DIAGONAL LAGRANGE LAGRANGE
              LH=JSCHC+IADL-1
              ZI(LH)=MAX(ZI(LH),1)
95          CONTINUE


40        CONTINUE
        ENDIF
10    CONTINUE
      ELSEIF (TYPROF.EQ.'PLEIN') THEN
        WRITE(6,*) 'PROFIL PLEIN!!!!'
        DO 15 I=1,NEQ
          ZI(JSCHC+I-1)=I
15      CONTINUE
      ENDIF


C---------------DETERMINATION DE LA TAILLE MAX D'UNE COLONNE------------
      LCOMOY=0
      LCOLMX=0
      DO 100 I=1,NEQ
        LCOLMX=MAX(LCOLMX,ZI(JSCHC+I-1))
        LCOMOY=LCOMOY+ZI(JSCHC+I-1)
100   CONTINUE

      LCOMOY=LCOMOY/NEQ

      IF(LCOLMX.GT.NTBLOC) THEN
        NTBLOC=LCOLMX
        VALR (1) = RTBLOC
        VALR (2) = LCOLMX/1.D+3
        CALL U2MESG('I', 'ALGORITH14_66',0,' ',0,0,2,VALR)
      ENDIF

      WRITE(IFIMES,*)'+++ HAUTEUR MAXIMUM D''UNE COLONNE: ',LCOLMX
      WRITE(IFIMES,*)'+++ HAUTEUR MOYENNE D''UNE COLONNE: ',LCOMOY


C----------------DETERMINATION DU NOMBRE DE BLOCS-----------------------
      NBLOC=1
      NTERBL=0
      NTERMX=0
      CALL WKVECT(STOLCI//'.SCIB','G V I',NEQ,JSCIB)
      DO 110 I=1,NEQ
        NTERM=NTERBL+ZI(JSCHC+I-1)
        IF(NTERM.GT.NTBLOC) THEN
          NBLOC=NBLOC+1
          NTERBL=ZI(JSCHC+I-1)
          NTERMX=MAX(NTERMX,NTERBL)
        ELSE
          NTERBL=NTERM
          NTERMX=MAX(NTERMX,NTERBL)
        ENDIF
        ZI(JSCIB+I-1)=NBLOC
110   CONTINUE

      WRITE(IFIMES,*)'+++ NOMBRE DE BLOCS DU STOCKAGE: ',NBLOC


C-------------DERNIERE BOUCLE SUR LES BLOCS POUR  SCDI ET SCBL----------
C  ON REDUIT LA TAILLE DES BLOCS A LA TAILLE UTILE MAX (GAIN DE PLACE)

      NTBLOC=NTERMX
      CALL WKVECT(STOLCI//'.SCBL','G V I',NBLOC+1,JSCBL)
      CALL WKVECT(STOLCI//'.SCDI','G V I',NEQ,JSCDI)

      NTERBL=0
      NBLOC=1
      ZI(JSCBL)=0

      DO 120 I=1,NEQ
        NTERM=NTERBL+ZI(JSCHC+I-1)
        IF(NTERM.GT.NTBLOC) THEN
          NTERBL=ZI(JSCHC+I-1)
          NBLOC=NBLOC+1
        ELSE
          NTERBL=NTERM
        ENDIF
         ZI(JSCBL+NBLOC)=I
        ZI(JSCDI+I-1)=NTERBL
120   CONTINUE


C     -- .SCDE
      CALL WKVECT(STOLCI//'.SCDE','G V I',6,JSCDE)
      ZI(JSCDE-1+1)=NEQ
      ZI(JSCDE-1+2)=NTBLOC
      ZI(JSCDE-1+3)=NBLOC
      ZI(JSCDE-1+4)=LCOLMX


C     -- ON TRANSFORME LE STOCKAGE LIGNE_CIEL EN STOCKAGE MORSE :
      CALL SLISMO(STOLCI,STOMOR,'G')


 9999 CONTINUE
      CALL JEDEMA()
      END
