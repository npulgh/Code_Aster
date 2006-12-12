      SUBROUTINE PALIMA(NOMAZ,MCFACT,MCGRMA,MCMA,IOCC,NOML)
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*)     NOMAZ,MCFACT,MCGRMA,MCMA     ,NOML
      INTEGER                                   IOCC
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/12/2006   AUTEUR PELLET J.PELLET 
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
C
C BUT : LECTURE DE LA LISTE DES MAILLES DESCRITES PAR LA SEQUENCE :
C       MCFAC : ( MCGRMA : LISTE DE GROUP_MA ,
C                 MCMA   : LISTE DE MAILLE   , ....)
C       CREATION D'UN OBJET DE NOM : NOML  OJB V V I DIM=NBMA*2+1
C       NBMA : NOMBRE DE MAILLES LUES
C       NOML(1) = NBMA  NOML(1+2*(I-1)+1)=IMA NUM.DE LA MAILLE DANS NOMA
C                       NOML(1+2*(I-1)+2)=ITYP NUM.DU TYPE_MAIL DE IMA
C       LES MAILLES SONT TRIEES EN PAQUETS DE MEME TYPEMAIL
C
C IN   NOMAZ   : NOM DU MAILLAGE
C IN   MCFACT K*(*) : MOT CLE FACTEUR
C IN   MCGRMA K*(*) : MOT CLE CONSERNANT LA LISTE DE GROUP_MA
C IN   MCMA   K*(*) : MOT CLE CONSERNANT LA LISTE DE MAILLE
C IN   IOCC   I     : NUMERO DE L'OCCURENCE DU MOT CLE FACTEUR
C OUT  NOML   K*24  : NOM DE L'OBJET JEVEUX CREE SUR LA VOLATILE
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      INTEGER      NGR,NMA,IBID,IATYMA
      CHARACTER*8  K8BID,NOMA
      CHARACTER*16 MCF,MCGM,MCM
      CHARACTER*24 LISTE,LMA,LGRMA,NOMAGR,NOMAMA,NOMATY,LN
      CHARACTER*24 VALK(4)
C --- DEBUT
      CALL JEMARQ()
      NOMA = NOMAZ
      MCF = MCFACT
      MCGM = MCGRMA
      MCM = MCMA
      NOMAMA = NOMA//'.NOMMAI'
      NOMAGR = NOMA//'.GROUPEMA'
      NOMATY = NOMA//'.TYPMAIL'
      LISTE = NOML
      CALL JEEXIN(LISTE,IRET)
      IF (IRET.NE.0) CALL JEDETR(LISTE)
      LGRMA = '&&PALIMA.LISTEGRMA'
      LN    = '&&PALIMA.LISTEGRMA.N'
      LMA   = '&&PALIMA.LISTEMA'
      NBMAGR = 0
      CALL GETVID(MCFACT,MCGRMA,IOCC,1,0,K8BID,NGR)
      IER = 0
      IF (NGR.LT.0) THEN
        NGR = -NGR
        CALL WKVECT(LGRMA,'V V K8',NGR,IGRMA)
        CALL WKVECT(LN   ,'V V I',NGR,IDN)
        CALL GETVID(MCFACT,MCGRMA,IOCC,1,NGR,ZK8(IGRMA),IBID)
        DO 1 I = 1,NGR
          CALL JENONU(JEXNOM(NOMAGR,ZK8(IGRMA-1+I)),IRET)
          IF (IRET .EQ. 0) THEN
             VALK(1) = MCF
             VALK(2) = MCGM
             VALK(3) = ZK8(IGRMA-1+I)
             VALK(4) = NOMA
             CALL U2MESK('E','MODELISA6_13', 4 ,VALK)
            IER = IER + 1
          ELSE
            CALL JELIRA(JEXNOM(NOMAGR,ZK8(IGRMA-1+I)),'LONMAX',N,K8BID)
            ZI(IDN-1+I) = N
            NBMAGR = NBMAGR+N
          ENDIF
1       CONTINUE
      ENDIF
      IF (IER.NE.0) THEN
        VALK(1) = MCF
        VALK(2) = MCGM
        CALL U2MESK('F','MODELISA6_14', 2 ,VALK)
      ENDIF
      LMA   = '&&PALIMA.LISTEMA'
      CALL GETVID(MCFACT,MCMA,IOCC,1,0,K8BID,NMA)
      NMA = -NMA
      NBMA = NBMAGR+NMA
      CALL WKVECT(LISTE,'V V I',2*NBMA+1,ILISTE)
      ZI(ILISTE) = NBMA
      IMA = 0
      IF (NBMAGR.GT.0) THEN
        DO 2 I = 1,NGR
          CALL JEVEUO(JEXNOM(NOMAGR,ZK8(IGRMA-1+I)),'L',JGR)
          DO 3 J = 1,ZI(IDN+I-1)
            IMA = IMA +1
            NUMA = ZI(JGR-1+J)
            CALL JEVEUO(NOMATY,'L',IATYMA)
            ITYP=IATYMA-1+NUMA
            NUTYP = ZI(ITYP)
            IMAL= ILISTE + 2*(IMA-1)+1
            ZI(IMAL) = NUMA
            ZI(IMAL+1) = NUTYP
3         CONTINUE
2       CONTINUE
        CALL JEDETR(LGRMA)
        CALL JEDETR(LN)
      ENDIF
      IF (NMA.GT.0) THEN
        CALL WKVECT(LMA,'V V K8',NMA,ILMA)
        CALL GETVID(MCFACT,MCMA,IOCC,1,NMA,ZK8(ILMA),IBID)
        DO 4 J = 1,NMA
          IMA = IMA +1
          CALL JENONU(JEXNOM(NOMAMA,ZK8(ILMA+J-1)),NUMA)
          IF (NUMA .EQ. 0) THEN
             VALK(1) = MCF
             VALK(2) = MCM
             VALK(3) = ZK8(ILMA-1+J)
             VALK(4) = NOMA
             CALL U2MESK('E','MODELISA6_15', 4 ,VALK)
            IER = IER + 1
          ELSE
            CALL JEVEUO(NOMATY,'L',IATYMA)
            ITYP=IATYMA-1+NUMA
            NUTYP = ZI(ITYP)
            IMAL= ILISTE + 2*(IMA-1)+1
            ZI(IMAL) = NUMA
            ZI(IMAL+1) = NUTYP
          ENDIF
4       CONTINUE
        CALL JEDETR(LMA)
      ENDIF
      IF (IER.NE.0) THEN
        VALK(1) = MCF
        VALK(2) = MCM
        CALL U2MESK('F','MODELISA6_14', 2 ,VALK)
      ENDIF
C
C --- TRI DES MAILLES PAR PAQUET AYANT MEME TYPEMAIL
C
      IMA = 0
      NUTYC = 0
      DO 5 I = 1, NBMA
        IMA = IMA+1
        IF (IMA.GE.NBMA) GOTO 50
        IMAL = ILISTE+2*(IMA-1)+1
        NUTY = ZI(IMAL+1)
        IMAC = IMA
        DO 6 J = IMA+1,NBMA
          JMAL = ILISTE+2*(J-1)+1
          NUTYC = ZI(JMAL+1)
          IF (NUTYC.EQ.NUTY) THEN
            IMAC = IMAC+1
            KMAL = ILISTE+2*(IMAC-1)+1
            KMA = ZI(KMAL)
            KTY = ZI(KMAL+1)
            ZI(KMAL) = ZI(JMAL)
            ZI(KMAL+1) = NUTY
            ZI(JMAL) = KMA
            ZI(JMAL+1) = KTY
          ENDIF
6       CONTINUE
        IMA = IMAC
5     CONTINUE
50    CONTINUE
      CALL JEDEMA()
      END
