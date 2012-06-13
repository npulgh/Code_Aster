      SUBROUTINE NUMGEN(NUGENE,MODGEN)
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
C***********************************************************************
C    P. RICHARD     DATE 13/10/92
C-----------------------------------------------------------------------
C  BUT:      < NUMEROTATION GENERALISEE >
      IMPLICIT REAL*8(A-H,O-Z)
C
C  DETERMINER LA NUMEROTATION DES DEGRES DE LIBERTE GENERALISES
C   A PARTIR D'UN MODELE GENERALISE
C
C-----------------------------------------------------------------------
C
C NUGENE   /I/: NOM K14 DU NUME_DDL_GENE
C MODGEN   /I/: NOM K8 DU MODELE GENERALISE
C
C
C
      INCLUDE 'jeveux.h'
C
C
      INTEGER LDDELG
      CHARACTER*6 PGC
      CHARACTER*8 MODGEN,NOMCOU,SST1,SST2,KBID
      CHARACTER*14 NUGENE
      CHARACTER*19 PRGENE
      CHARACTER*24 DEFLI,FPROFL,NOMSST
      CHARACTER*24 VALK
      LOGICAL ASSOK,PBCONE
      CHARACTER*8 BID
C
      CHARACTER*1 K8BID
C
C-----------------------------------------------------------------------
      DATA PGC/'NUMGEN'/
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      IFIMES=IUNIFI('MESSAGE')
C
C-----------------------------------------------------------------------
C
      DEFLI=MODGEN//'      .MODG.LIDF'
      FPROFL=MODGEN//'      .MODG.LIPR'
      NOMSST=MODGEN//'      .MODG.SSNO'
C
C--------------------CREATION DU .REFN----------------------------------
C                       ET DU DESC
      PRGENE=NUGENE//'.NUME'
      CALL WKVECT(PRGENE//'.REFN','G V K24',4,JREFN)
      ZK24(JREFN)=MODGEN
      ZK24(JREFN+1)='DEPL_R'
      CALL WKVECT(PRGENE//'.DESC','G V I',1,LDDESC)
      ZI(LDDESC)=2
C
C---------------------------DECLARATION JEVEUX--------------------------
C
      CALL JECREO(PRGENE//'.LILI','G N K8')
      CALL JEECRA(PRGENE//'.LILI','NOMMAX',2,K8BID)
      CALL JECROC(JEXNOM(PRGENE//'.LILI','&SOUSSTR'))
      CALL JECROC(JEXNOM(PRGENE//'.LILI','LIAISONS'))
C
      CALL JECREC(PRGENE//'.PRNO','G V I','NU','DISPERSE','VARIABLE',2)
      CALL JECREC(PRGENE//'.ORIG','G V I','NU','DISPERSE','VARIABLE',2)
C
C----------------------RECUPERATION DES DIMENSIONS PRINCIPALES----------
C
      CALL JELIRA(DEFLI,'NMAXOC',NBLIA,BID)
      CALL JELIRA(NOMSST,'NOMMAX',NBSST,BID)
C
C-----------------------------ECRITURE DIMENSIONS-----------------------
C
      CALL JENONU(JEXNOM(PRGENE//'.LILI','&SOUSSTR'),IBID)
      CALL JEECRA(JEXNUM(PRGENE//'.PRNO',IBID),'LONMAX',NBSST*2,' ')
      CALL JENONU(JEXNOM(PRGENE//'.LILI','LIAISONS'),IBID)
      CALL JEECRA(JEXNUM(PRGENE//'.PRNO',IBID),'LONMAX',NBLIA*4,' ')
      CALL JENONU(JEXNOM(PRGENE//'.LILI','&SOUSSTR'),IBID)
      CALL JEECRA(JEXNUM(PRGENE//'.ORIG',IBID),'LONMAX',NBSST,' ')
      CALL JENONU(JEXNOM(PRGENE//'.LILI','LIAISONS'),IBID)
      CALL JEECRA(JEXNUM(PRGENE//'.ORIG',IBID),'LONMAX',NBLIA*2,' ')
C
C----------------------BOUCLES DE COMPTAGE DES DDL----------------------
C
      ICOMP=0
      ICOMPS=0
      ICOMPL=0
C
C   BOUCLE SUR LES SOUS-STRUCTURES
C
      CALL JENONU(JEXNOM(PRGENE//'.LILI','&SOUSSTR'),IBID)
      CALL JEVEUO(JEXNUM(PRGENE//'.PRNO',IBID),'E',LDPRS)
      CALL JENONU(JEXNOM(PRGENE//'.LILI','&SOUSSTR'),IBID)
      CALL JEVEUO(JEXNUM(PRGENE//'.ORIG',IBID),'E',LDORS)
C
      DO 10 I=1,NBSST
        KBID='        '
        CALL MGUTDM(MODGEN,KBID,I,'NOM_MACR_ELEM',IBID,NOMCOU)
        ZI(LDORS+I-1)=I
        CALL JEVEUO(NOMCOU//'.MAEL_RAID_DESC','L',LLDESC)
        NBMOD=ZI(LLDESC+1)
        ZI(LDPRS+(I-1)*2+1)=NBMOD
        ICOMP=ICOMP+NBMOD
        ICOMPS=ICOMPS+NBMOD
   10 CONTINUE
C
C   BOUCLE SUR LES LIAISONS
C   (ON SUPPOSE QUE LES MATRICES DES LIAISONS 1 ET 2 ONT
C   MEME NOMBRE DE LIGNES = VERIF VERILI)
C
      CALL JENONU(JEXNOM(PRGENE//'.LILI','LIAISONS'),IBID)
      CALL JEVEUO(JEXNUM(PRGENE//'.PRNO',IBID),'E',LDPRL)
      CALL JENONU(JEXNOM(PRGENE//'.LILI','LIAISONS'),IBID)
      CALL JEVEUO(JEXNUM(PRGENE//'.ORIG',IBID),'E',LDORL)
      CALL JEVEUO(FPROFL,'L',LLPROF)
C
      DO 20 I=1,NBLIA
        NBLIG=ZI(LLPROF+(I-1)*9)
        ZI(LDORL+(I-1)*2)=I
        ZI(LDORL+(I-1)*2+1)=I
        ZI(LDPRL+(I-1)*4+1)=NBLIG
        ZI(LDPRL+(I-1)*4+3)=NBLIG
        ICOMP=ICOMP+2*NBLIG
        ICOMPL=ICOMPL+2*NBLIG
   20 CONTINUE
C
      NEQ=ICOMP
C
      WRITE (IFIMES,*)'+++ NOMBRE DE SOUS-STRUSTURES: ',NBSST
      WRITE (IFIMES,*)'+++ NOMBRE DE LIAISONS: ',NBLIA
      WRITE (IFIMES,*)'+++ NOMBRE TOTAL D''EQUATIONS: ',NEQ
      WRITE (IFIMES,*)'+++ DONT NOMBRE D''EQUATIONS STRUCTURE: ',ICOMPS
      WRITE (IFIMES,*)'+++ DONT NOMBRE D''EQUATIONS LIAISON: ',ICOMPL
C
      CALL WKVECT(PRGENE//'.NEQU','G V I',1,LDNEQU)
      ZI(LDNEQU)=NEQ
C
C------------------------ALLOCATIONS DIVERSES---------------------------
C
      CALL WKVECT(PRGENE//'.DEEQ','G V I',NEQ*2,LDDEEQ)
      CALL WKVECT(PRGENE//'.NUEQ','G V I',NEQ,LDNUEQ)
      CALL WKVECT(PRGENE//'.DELG','G V I',NEQ,LDDELG)
C
      CALL WKVECT('&&'//PGC//'.SST.NBLIA','V V I',NBSST,LTSSNB)
      CALL WKVECT('&&'//PGC//'.LIA.SST','V V I',NBLIA*2,LTLIA)
      CALL JECREC('&&'//PGC//'.SST.LIA','V V I','NU','DISPERSE',
     &            'CONSTANT',NBSST)
      CALL JEECRA('&&'//PGC//'.SST.LIA','LONMAX',2*NBLIA,' ')
C
C   BOUCLE DE DETERMINATION DE LA RELATION
C   NUMERO TARDIF  LIAISON --> NUMERO SOUS-STRUCTURE DE PLUS PETIT
C                              NUMERO
C
      DO 30 I=1,NBLIA*2
        NULIA=ZI(LDORL+I-1)
        CALL JEVEUO(JEXNUM(DEFLI,NULIA),'L',LLDEFL)
        SST1=ZK8(LLDEFL)
        SST2=ZK8(LLDEFL+2)
        CALL JENONU(JEXNOM(NOMSST,SST1),NUSST1)
        CALL JENONU(JEXNOM(NOMSST,SST2),NUSST2)
        ZI(LTSSNB+NUSST1-1)=1
        ZI(LTSSNB+NUSST2-1)=1
        ZI(LTLIA+I-1)=MAX(NUSST1,NUSST2)
   30 CONTINUE
C
C   BOUCLE PERMETTANT DE DETERMINER L'INVERSE
C   NUMERO TARDIF  SOUS-STRUCTURE --> NUMEROS TARDIF LIAISONS
C                     DONT ELLE EST LA STRUCTURE DE PLUS PETIT NUMERO
C
C   ET POUR DETECTER LES SOUS-STRUCTURES NON CONNECTEES
C
      PBCONE=.FALSE.
      DO 50 I=1,NBSST
        ICOMP=0
        NUSST=ZI(LDORS+I-1)
        IF (ZI(LTSSNB+NUSST-1).EQ.0) THEN
          PBCONE=.TRUE.
          CALL JENUNO(JEXNUM(NOMSST,NUSST),SST1)
          VALK=SST1
          CALL U2MESG('E','ALGORITH13_75',1,VALK,0,0,0,0.D0)
        ENDIF
        CALL JECROC(JEXNUM('&&'//PGC//'.SST.LIA',I))
        CALL JEVEUO(JEXNUM('&&'//PGC//'.SST.LIA',I),'E',LTSST)
        DO 40 J=1,NBLIA*2
          IF (ZI(LTLIA+J-1).EQ.NUSST) THEN
            ICOMP=ICOMP+1
            ZI(LTSST+ICOMP-1)=J
          ENDIF
   40   CONTINUE
   50 CONTINUE
C
      IF (PBCONE) THEN
        CALL U2MESG('F','ALGORITH13_76',0,' ',0,0,0,0.D0)
      ENDIF
C
      CALL JEDETR('&&'//PGC//'.LIA.SST')
      CALL JEDETR('&&'//PGC//'.SST.NBLIA')
C
C--------------------DETERMINATION DE L'ORDRE D'ASSEMBLAGE--------------
C                            DES NOEUDS TARDIFS
C
      NTAIL=NBSST+2*NBLIA
      CALL WKVECT('&&'//PGC//'.ORD.ASS','V V I',NTAIL,LTORAS)
C
C   BOUCLE SUR LES SOUS-STRUCTURES
C
      ICOMP=0
      DO 100 I=1,NBSST
        CALL JEVEUO(JEXNUM('&&'//PGC//'.SST.LIA',I),'L',LTSST)
C
C  BOUCLE SUR LES LIAISONS POUR ASSEMBLAGES DES DUALISATION AVANT
C
        DO 70 J=1,NBLIA*2
          ASSOK=.TRUE.
          NUTARL=ZI(LTSST+J-1)
          NULIA=ZI(LDORL+NUTARL-1)
          IF (NUTARL.GT.0) THEN
C
C   BOUCLE SUR LES NOEUDS TARDIFS DE LIAISON DE LA SOUS-STRUCTURE
C   COURANTE POUR EVITER LES DOUBLES ASSEMBLAGES
C   (NE PAS ASSEMBLER AVANT CE QUI DOIT L'ETRE APRES)
C
            IF (J.NE.1) THEN
              DO 60 K=1,J-1
                NULT=ZI(LTSST+K-1)
                NULL=ZI(LDORL+NULT-1)
                IF (NULL.EQ.NULIA .AND. NULT.NE.0)ASSOK=.FALSE.
   60         CONTINUE
            ENDIF
            IF (ASSOK) THEN
              ICOMP=ICOMP+1
              ZI(LTORAS+ICOMP-1)=-NUTARL
            ENDIF
          ENDIF
   70   CONTINUE
C
C  ASSEMBLAGE DE LA SOUS-STRUCTURE COURANTE
C
        ICOMP=ICOMP+1
        ZI(LTORAS+ICOMP-1)=I
C
C   ASSEMBLAGE DES DUALISATIONS APRES LA SOUS-STRUCTURE COURANTE
C
        DO 90 J=1,NBLIA*2
          ASSOK=.TRUE.
          NUTARL=ZI(LTSST+J-1)
          IF (NUTARL.GT.0) THEN
            DO 80 K=1,ICOMP
              NUT=-ZI(LTORAS+K-1)
              IF (NUT.EQ.NUTARL)ASSOK=.FALSE.
   80       CONTINUE
            IF (ASSOK) THEN
              ICOMP=ICOMP+1
              ZI(LTORAS+ICOMP-1)=-NUTARL
            ENDIF
          ENDIF
   90   CONTINUE
  100 CONTINUE
C
      CALL JEDETR('&&'//PGC//'.SST.LIA')
C
C--------------------REMPLISSAGE DES NUMERO D'EQUATION-----------------
C
      ICOMP=1
C
      DO 120 I=1,NTAIL
        NUAS=ZI(LTORAS+I-1)
C
C  CAS DE LA SOUS-STRUCTURE
        IF (NUAS.GT.0) THEN
          NBDDL=ZI(LDPRS+(NUAS-1)*2+1)
          ZI(LDPRS+(NUAS-1)*2)=ICOMP
C
C CAS DE LA LIAISON
        ELSE
          NBDDL=ZI(LDPRL-(NUAS+1)*2+1)
          ZI(LDPRL-(NUAS+1)*2)=ICOMP
        ENDIF
C
        DO 110 J=ICOMP,ICOMP+NBDDL-1
          ZI(LDNUEQ+J-1)=J
          ZI(LDDELG+J-1)=0
          ZI(LDDEEQ+2*J-1)=NUAS
          ZI(LDDEEQ+2*J-2)=J-ICOMP+1
  110   CONTINUE
        ICOMP=ICOMP+NBDDL
  120 CONTINUE
C
C----------------------SAUVEGARDES DIVERSES-----------------------------
C
      CALL JEDETR('&&'//PGC//'.ORD.ASS')
C
      CALL JEDEMA()
      END
