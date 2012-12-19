      SUBROUTINE JJLCHD (ID, IC, IDFIC, IDTS, NGRP)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF JEVEUX  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
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
C ----------------------------------------------------------------------
C LECTURE SUR FICHIER HDF D'UNE COLLECTION PUIS LIBERATION
C
C IN  ID    : IDENTIFICATEUR DE COLLECTION
C IN  IC    : CLASSE ASSOCIEE
C IN  IDFIC : IDENTIFICATEUR DU FICHIER HDF
C IN  IDTS  : IDENTIFICATEUR DU DATASET ASSOCIE A LA COLLECTION
C IN  NGRP  : NOM DU GROUPE CONTENANT LE DATASET IDTS
C
C ----------------------------------------------------------------------
C RESPONSABLE LEFEBVRE J-P.LEFEBVRE
      IMPLICIT NONE
      INCLUDE 'jeveux_private.h'
      INTEGER            ID, IC, IDFIC, IDTS
      CHARACTER*(*)      NGRP
C ----------------------------------------------------------------------
      INTEGER          LK1ZON , JK1ZON , LISZON , JISZON
      COMMON /IZONJE/  LK1ZON , JK1ZON , LISZON , JISZON
C ----------------------------------------------------------------------
      INTEGER          N
      PARAMETER  ( N = 5 )
      INTEGER          JLTYP   , JLONG   , JDATE   , JIADD   , JIADM   ,
     &                 JLONO   , JHCOD   , JCARA   , JLUTI   , JMARQ
      COMMON /JIATJE/  JLTYP(N), JLONG(N), JDATE(N), JIADD(N), JIADM(N),
     &                 JLONO(N), JHCOD(N), JCARA(N), JLUTI(N), JMARQ(N)
      INTEGER          JGENR   , JTYPE   , JDOCU   , JORIG   , JRNOM
      COMMON /JKATJE/  JGENR(N), JTYPE(N), JDOCU(N), JORIG(N), JRNOM(N)
      INTEGER          LBIS , LOIS , LOLS , LOR8 , LOC8
      COMMON /IENVJE/  LBIS , LOIS , LOLS , LOR8 , LOC8
C ----------------------------------------------------------------------
      INTEGER          ISTAT
      COMMON /ISTAJE/  ISTAT(4)
      INTEGER          IPGC,KDESMA(2),LGD,LGDUTI,KPOSMA(2),LGP,LGPUTI
      COMMON /IADMJE/  IPGC,KDESMA,   LGD,LGDUTI,KPOSMA,   LGP,LGPUTI
C
      INTEGER          NUMEC
      COMMON /INUMJE/  NUMEC
      CHARACTER *24                     NOMCO
      CHARACTER *32    NOMUTI , NOMOS ,         NOMOC , BL32
      COMMON /NOMCJE/  NOMUTI , NOMOS , NOMCO , NOMOC , BL32
      INTEGER          ICLAS ,ICLAOS , ICLACO , IDATOS , IDATCO , IDATOC
      COMMON /IATCJE/  ICLAS ,ICLAOS , ICLACO , IDATOS , IDATCO , IDATOC
C ----------------------------------------------------------------------
      INTEGER         IDDESO     , IDIADD     , IDIADM     ,
     &               IDMARQ                ,
     &               IDLONO          , IDNUM
      PARAMETER    (  IDDESO = 1 , IDIADD = 2 , IDIADM = 3 ,
     &               IDMARQ = 4   ,
     &               IDLONO = 8  , IDNUM  = 10 )
C     ------------------------------------------------------------------
      INTEGER          ILOREP , IDENO    , IDEHC
      PARAMETER      ( ILOREP=1,IDENO=2,IDEHC=6)
C     ------------------------------------------------------------------
      CHARACTER*32     NOMO,NGRC,D32
      CHARACTER*8      NREP(2)
      CHARACTER*1      GENRI,TYPEI,TYPEB
      INTEGER          ITAB(1),IDA,JCTAB,NBOB,IDO,IDGR,ICONV
      INTEGER          HDFRSV,HDFOPG,HDFCLG,HDFNBO,HDFOPD,HDFCLD,HDFTSD
      INTEGER          IADMI,LTYPI,LONOI,LTYPB,LON
      INTEGER          IBACOL,IRET,K,IX,IXIADD,IXIADM,IXMARQ,IXDESO,IDGC
      INTEGER          IBIADM,IBMARQ,IBLONO,IDT1,IDT2,NBVAL,KITAB,IXLONO
      INTEGER          IADYN
      DATA             NREP / 'T_HCOD' , 'T_NOM' /
      DATA             D32 /'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'/
C DEB ------------------------------------------------------------------
      ICONV  = 0
      ICLAS  = IC
      ICLACO = IC
      IDATCO = ID
      NOMOS  = D32
      NOMCO  = RNOM(JRNOM(IC)+ID)(1:24)
      NOMOC  = D32
      GENRI  = GENR (JGENR(IC) + ID)
      TYPEI  = TYPE (JTYPE(IC) + ID)
      LTYPI  = LTYP (JLTYP(IC) + ID)
      LON    = LONO (JLONO(IC) + ID)
      LONOI  = LON * LTYPI
      IADM (JIADM(IC) + 2*ID-1) = 0
      IADM (JIADM(IC) + 2*ID  ) = 0
      IADD (JIADD(IC) + 2*ID-1) = 0
      IADD (JIADD(IC) + 2*ID  ) = 0
      LTYPB = 0
      TYPEB = ' '
C ------- OBJET CONTENANT LES IDENTIFICATEURS DE LA COLLECTION
      CALL JJLIHD (IDTS,LON,LONOI,GENRI,TYPEI,LTYPI,IC,ID,
     &             0,IMARQ(JMARQ(IC)+2*ID-1),IBACOL,IADYN)
      IADM (JIADM(IC)+2*ID-1) = IBACOL
      IADM (JIADM(IC)+2*ID  ) = IADYN
C
      DO 20 K = IDIADD,IDNUM
C     ----------- OBJETS ATTRIBUTS DE COLLECTION
        IX  = ISZON(JISZON + IBACOL + K)
        IF ( IX .GT. 0 ) THEN
          GENRI = GENR (JGENR(IC) + IX)
          NOMO  = RNOM (JRNOM(IC) + IX)
          TYPEI = TYPE (JTYPE(IC) + IX)
          LTYPI = LTYP (JLTYP(IC) + IX)
          LON   = LONO (JLONO(IC) + IX)
          LONOI = LON  * LTYPI
          IADD (JIADD(IC) + 2*IX-1) = 0
          IADD (JIADD(IC) + 2*IX  ) = 0
          IF ( GENRI .NE. 'N' )THEN
            IDA = HDFOPD(IDFIC,NGRP,NOMO)
            IF ( IDA .LT. 0 ) THEN
              CALL U2MESK('F','JEVEUX1_52',1,NOMO)
            ENDIF
            IADMI = 0
            IF (K.EQ.IDIADM .OR. K.EQ.IDMARQ .OR. K.EQ.IDIADD) THEN
C --------- MISE EN MEMOIRE SANS LECTURE SUR FICHIER HDF
              CALL JJALLS(LONOI, IC, GENRI, TYPEI, LTYPI, 'INIT',
     &                    ITAB, JCTAB, IADMI, IADYN)
              CALL JJECRS (IADMI,IC,IX,0,'E',
     &               IMARQ(JMARQ(IC)+2*IX-1))
            ELSE
C --------- MISE EN MEMOIRE AVEC LECTURE DISQUE SUR FICHIER HDF
              CALL JJLIHD (IDA,LON,LONOI,GENRI,TYPEI,LTYPI,IC,IX,
     &                     0,IMARQ(JMARQ(IC)+2*IX-1),IADMI,IADYN)
            ENDIF
            IADM(JIADM(IC)+2*IX-1) = IADMI
            IADM(JIADM(IC)+2*IX  ) = IADYN
            IRET = HDFCLD(IDA)
            CALL ASSERT(IRET .EQ. 0)
          ELSE
C-------- ON TRAITE UN REPERTOIRE DE NOMS
            IDGR=HDFOPG(IDFIC,NOMO)
            IDT1=HDFOPD(IDFIC,NOMO,NREP(1))
            IDT2=HDFOPD(IDFIC,NOMO,NREP(2))
            CALL JJALLS(LONOI,IC,GENRI,TYPEI,LTYPI,'INIT',ITAB,JCTAB,
     &                  IADMI,IADYN)
            CALL JJECRS(IADMI,IC,IX,0,'E',IMARQ(JMARQ(IC)+2*IX-1))
            IRET=HDFTSD(IDT1,TYPEB,LTYPB,NBVAL)
            CALL ASSERT(IRET .EQ. 0)
            CALL JJHRSV(IDT1,NBVAL,IADMI)
C
C           ON AJUSTE LA POSITION DES NOMS EN FONCTION DU TYPE D'ENTIER
C
            ISZON(JISZON+IADMI-1+IDENO)=
     &            (IDEHC+ISZON(JISZON+IADMI-1+ILOREP))*LOIS
            IRET=HDFTSD(IDT2,TYPEB,LTYPB,NBVAL)
            CALL ASSERT(IRET .EQ. 0)
            KITAB=JK1ZON+(IADMI-1)*LOIS+ISZON(JISZON+IADMI-1+IDENO)+1
            IRET=HDFRSV(IDT2,NBVAL,K1ZON(KITAB),ICONV)
            CALL ASSERT(IRET .EQ. 0)
            IRET=HDFCLG(IDGR)
            CALL ASSERT(IRET .EQ. 0)
            IADM(JIADM(IC)+2*IX-1) = IADMI
            IADM(JIADM(IC)+2*IX  ) = IADYN
            IRET = HDFCLD(IDT2)
            CALL ASSERT(IRET .EQ. 0)
          ENDIF
        ENDIF
 20   CONTINUE
      IXIADD = ISZON(JISZON + IBACOL + IDIADD)
      IXIADM = ISZON(JISZON + IBACOL + IDIADM)
      IXMARQ = ISZON(JISZON + IBACOL + IDMARQ)
      IXDESO = ISZON(JISZON + IBACOL + IDDESO)
      IF ( IXIADD .EQ. 0 ) THEN
C       COLLECTION CONTIGUE, ELLE PEUT ETRE LIBEREE IMMEDIATEMENT APRES
C       RELECTURE DU $$DESO
        GENRI = GENR(JGENR(IC) + IXDESO)
        TYPEI = TYPE(JTYPE(IC) + IXDESO)
        LTYPI = LTYP(JLTYP(IC) + IXDESO)
        LON   = LONO(JLONO(IC) + IXDESO)
        LONOI = LON  * LTYPI
        NOMO  = RNOM(JRNOM(IC) + IXDESO)
        IDA = HDFOPD(IDFIC,NGRP,NOMO)
        CALL JJLIHD(IDA,LON,LONOI,GENRI,TYPEI,LTYPI,IC,IXDESO,
     &              0,IMARQ(JMARQ(IC)+2*IXDESO-1),IADMI,IADYN)
        IADM(JIADM(IC)+2*IXDESO-1) = IADMI
        IADM(JIADM(IC)+2*IXDESO  ) = IADYN
        IRET = HDFCLD(IDA)
        CALL ASSERT(IRET .EQ. 0)
      ELSE
C       COLLECTION DISPERSEE, IL FAUT RELIRE LES OBJETS STOCKES SUR LE
C       FICHIER HDF DANS LE GROUPE ASSOCIE ET UNIQUEMENT ACTUALISER LES
C       ADRESSES MEMOIRE DANS L'OBJET SYSTEME $$IADM
        IBIADM = IADM(JIADM(IC)+2*IXIADM-1)
        IBMARQ = IADM(JIADM(IC)+2*IXMARQ-1)
        IXLONO = ISZON (JISZON + IBACOL + IDLONO)
        GENRI  = GENR(JGENR(IC)+IXDESO)
        TYPEI  = TYPE(JTYPE(IC)+IXDESO)
        LTYPI  = LTYP(JLTYP(IC)+IXDESO)
        NGRC = RNOM(JRNOM(IC)+ID)(1:24)//'__OBJETS'
        IDGC = HDFOPG(IDFIC,NGRC)
        NBOB = HDFNBO(IDFIC,NGRC)
        NOMO = RNOM(JRNOM(IC)+ID)(1:24)
        DO 30 K=1,NBOB
          WRITE(NOMO(25:32),'(I8)') K
          IF (IXLONO .EQ. 0) THEN
            LONOI = LONO (JLONO(IC) + IXDESO) * LTYPI
          ELSE
            IBLONO = IADM  (JIADM(IC) + 2*IXLONO-1)
            LONOI  = ISZON (JISZON + IBLONO - 1 + K) * LTYPI
          ENDIF
          IF (LONOI .GT. 0) THEN
            IDO=HDFOPD(IDFIC,NGRC,NOMO)
            IRET=HDFTSD(IDO,TYPEB,LTYPB,LON)
            CALL ASSERT(IRET .EQ. 0)
            CALL JJLIHD (IDO,LON,LONOI,GENRI,TYPEI,LTYPI,IC,K,
     &                   ID,ISZON(JISZON+IBMARQ-1+2*K-1),IADMI,IADYN)
            ISZON(JISZON+IBIADM-1+2*K-1) = IADMI
            ISZON(JISZON+IBIADM-1+2*K  ) = IADYN
            NUMEC = K
            CALL JJLIDE ('JELIBE' , RNOM(JRNOM(IC)+ID)//'$$XNUM  ' , 2)
            IRET = HDFCLD(IDO)
            CALL ASSERT(IRET .EQ. 0)
          ENDIF
30      CONTINUE
        IRET = HDFCLG(IDGC)
        CALL ASSERT(IRET .EQ. 0)
      ENDIF
      CALL JJLIDE ('JELIBE',RNOM(JRNOM(IC)+ID),2)
C FIN ------------------------------------------------------------------
      END
