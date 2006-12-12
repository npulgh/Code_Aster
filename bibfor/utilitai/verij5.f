      SUBROUTINE VERIJ5(TYPESD,NOMSD,M80,NVU)
      IMPLICIT NONE
      CHARACTER*(*) TYPESD,NOMSD,M80
      INTEGER NVU
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 13/12/2006   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE VABHHTS J.PELLET
C ----------------------------------------------------------------------
C  BUT : FAIRE UN ENSEMBLE DE VERIFICATIONS SUR UNE SD
C        => ERREUR <F> SI SD INCORRECTE
C  CETTE ROUTINE EFFECTUE LES VERIFICATIONS SPECIFIQUES QUI N'ONT PAS
C  PU ETRE FAITES DANS LA ROUTINE VERIJ1.F DEDUITE DU CATALOGUE DES SD :
C  PAR EXEMPLE : INDIRECTIONS, CHOIX, DETAILS DES OBJETS.
C-----------------------------------------------------------------------
C  IN   TYPESD : TYPE DE LA STRUCTURE DE DONNEE A TESTER
C          /'CHAM_NO'  /'CHAMP'  /'TABLE' /...
C       NOMSD   : NOM DE LA STRUCTURE DE DONNEES A TESTER

C ----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------

      INTEGER JREFA,I1,I2,I3,IBID,JSLVK,JDESC,J1,N2,K,J2,K2
      INTEGER JSCDE,JSMDE,JNOMA,JREFE,JNSLV,NPARA,NLIG
      INTEGER JDIME,N1,NBNO,NBMA,NBSM,NBNL,NBSMX,DIMCO
      INTEGER VERIOB,IEX1,IEXI,NOBJ
      CHARACTER*4 DOCU1,KBID
      CHARACTER*8 CH8,METRES,TYCH
      CHARACTER*14 CH14
      CHARACTER*16 TYP2SD
      CHARACTER*17 CH17
      CHARACTER*19 CH19,CHAMP
C -DEB------------------------------------------------------------------

C     RETURN
      CALL JEMARQ()
      TYP2SD = TYPESD
      NOBJ = 0


      IF (TYP2SD.EQ.'MAILLAGE') THEN
C     ------------------------------
        CALL VSDMAI(NOMSD)


      ELSEIF (TYP2SD.EQ.'LIGREL') THEN
C     ------------------------------
        CH19 = NOMSD

        CALL JELIRA(CH19//'.NOMA','DOCU',IBID,KBID)
        CALL ASSERT(KBID.EQ.' ' .OR. KBID.EQ.'THER' .OR. KBID.EQ.'MECA')
        CALL JEVEUO(CH19//'.NOMA','L',JNOMA)
        CALL VERIJA('O','MAILLAGE',ZK8(JNOMA-1+1) (1:8),M80,NVU,NOBJ)

        CALL JEEXIN(CH19//'.LIEL',I1)
        IF (I1.GT.0) THEN
        ENDIF



      ELSEIF (TYP2SD.EQ.'MODELE') THEN
C     ------------------------------
        CH8 = NOMSD
        CALL VERIJA('O','LIGREL',CH8//'.MODELE',M80,NVU,NOBJ)
        CALL JEEXIN(CH8//'.MAILLE',I1)
        CALL JEEXIN(CH8//'.SSSA',I2)
        CALL ASSERT(I1+I2.GT.0)
        IF (I1.GT.0) THEN

        ENDIF
        IF (I2.GT.0) THEN
        ENDIF


      ELSEIF (TYP2SD.EQ.'MODELE_GENE') THEN
C     -----------------------------------
        CALL VSDMOG(NOMSD)


      ELSEIF (TYP2SD.EQ.'MACR_ELEM_DYNA') THEN
C     -----------------------------------
        CALL VSDMCD(NOMSD)


      ELSEIF (TYP2SD.EQ.'CHAMP') THEN
C     ------------------------------
        CH19 = NOMSD
        CALL DISMOI('F','TYPE_CHAMP',CH19,'CHAMP',IBID,TYCH,IBID)
        IF (TYCH.EQ.'NOEU') THEN
          CALL VERIJA('O','CHAM_NO',CH19,M80,NVU,NOBJ)

        ELSEIF (TYCH.EQ.'CART') THEN
          CALL VERIJA('O','CARTE',CH19,M80,NVU,NOBJ)

        ELSEIF (TYCH(1:2).EQ.'EL') THEN
          CALL VERIJA('O','CHAM_ELEM',CH19,M80,NVU,NOBJ)

        ELSEIF (TYCH.EQ.'RESL') THEN
          CALL VERIJA('O','RESUELEM',CH19,M80,NVU,NOBJ)

        ELSEIF (TYCH.EQ.'VGEN') THEN
          CALL VERIJA('O','CHAM_GENE',CH19,M80,NVU,NOBJ)

        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF


      ELSEIF (TYP2SD.EQ.'CHAM_NO') THEN
C     ------------------------------
        CH19 = NOMSD
        CALL JEVEUO(CH19//'.DESC','L',JDESC)

        CALL JEVEUO(CH19//'.REFE','L',JREFE)
        CALL VERIJA('O','MAILLAGE',ZK24(JREFE-1+1),M80,NVU,NOBJ)
C       -- SI CHAM_NO "CONSTANT" : PAS DE PROF_CHNO:
        IF (ZI(JDESC-1+2).EQ.0) THEN
          CALL VERIJA('O','PROF_CHNO',ZK24(JREFE-1+2),M80,NVU,NOBJ)
        ENDIF


      ELSEIF (TYP2SD.EQ.'MATR_ELEM' .OR. TYP2SD.EQ.'VECT_ELEM') THEN
C     ---------------------------------------------------------------
        CH8 = NOMSD

        CALL JEVEUO(CH8//'.LISTE_RESU','L',J1)
C       -- IMPORTANT : UTILISATION DE LONUTI :
        CALL JELIRA(CH8//'.LISTE_RESU','LONUTI',N1,KBID)
        DO 10,K = 1,N1
          CHAMP = ZK24(J1-1+K)
          IF (CHAMP.EQ.' ') GOTO 10
C         -- IMPORTANT :
C         -- PARFOIS, CERTAINS RESUELEM N'EXISTENT PAS (ADLV100A)
          CALL JEEXIN(CHAMP//'.DESC',IEXI)
          IF (IEXI.EQ.0) GOTO 10
          CALL VERIJA('O','RESUELEM',CHAMP,M80,NVU,NOBJ)
   10   CONTINUE
   20   CONTINUE


      ELSEIF (TYP2SD.EQ.'SD_RESULTAT') THEN
C     --------------------------------
        CH8 = NOMSD
        CALL VSDRST(CH8,M80,NVU,NOBJ)


      ELSEIF (TYP2SD.EQ.'TABLE') THEN
C     --------------------------------
        CH17 = NOMSD
        CALL JEVEUO(CH17//'  .TBBA','L',J1)
        CALL ASSERT(ZK8(J1).EQ.'G' .OR. ZK8(J1).EQ.'V')

        CALL JEVEUO(CH17//'  .TBNP','L',J1)
        NPARA = ZI(J1-1+1)
        NLIG = ZI(J1-1+2)
        CALL ASSERT(NPARA.GT.0)
        CALL ASSERT(NLIG.GT.0)

        CALL JEVEUO(CH17//'  .TBLP','L',J1)
        CALL JELIRA(CH17//'  .TBLP','LONMAX',N1,KBID)
        N2 = N1/4
        CALL ASSERT(N1.EQ.N2*4)
        CALL ASSERT(N2.EQ.NPARA)
        DO 50,K = 1,NPARA

C         -- PARFOIS ON CREE DES FONCTIONS EN SOUS-TERRAIN :
          IF (ZK24(J1-1+4* (K-1)+1).NE.'FONCTION') GOTO 40
          IF (ZK24(J1-1+4* (K-1)+2).NE.'K24') GOTO 40

          CALL JEVEUO(ZK24(J1-1+4* (K-1)+3),'L',J2)
          CALL JELIRA(ZK24(J1-1+4* (K-1)+3),'LONMAX',N2,KBID)
          DO 30,K2 = 1,N2
            IF (ZK24(J2-1+K2).EQ.' ') GOTO 30
            CALL VERIJA('O','FONCTION',ZK24(J2-1+K2),M80,NVU,NOBJ)
   30     CONTINUE
   40     CONTINUE

   50   CONTINUE
   60   CONTINUE


      ELSEIF (TYP2SD.EQ.'MATR_ASSE') THEN
C     -----------------------------------
        CH19 = NOMSD
C       -- MATR_ASSE OU MATR_ASSE_GENE ? :
        CALL JEVEUO(CH19//'.REFA','L',JREFA)
        IF (ZK24(JREFA-1+10).EQ.'NOEU') THEN
          CALL VERIJA('O','MATR_ASSE_GD',CH19,M80,NVU,NOBJ)

        ELSEIF (ZK24(JREFA-1+10).EQ.'GENE') THEN
          CALL VERIJA('O','MATR_ASSE_GENE',CH19,M80,NVU,NOBJ)

        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF


      ELSEIF (TYP2SD.EQ.'MATR_ASSE_GD') THEN
C     -----------------------------------
        CH19 = NOMSD
        CALL JELIRA(CH19//'.REFA','DOCU',IBID,DOCU1)
        CALL ASSERT(DOCU1.EQ.' ')
        CALL JEVEUO(CH19//'.REFA','L',JREFA)
        CALL ASSERT(ZK24(JREFA-1+10).EQ.'NOEU')

        CALL VERIJA('O','MAILLAGE',ZK24(JREFA-1+1),M80,NVU,NOBJ)
        CALL VERIJA('O','NUME_DDL',ZK24(JREFA-1+2),M80,NVU,NOBJ)
        CALL ASSERT((ZK24(JREFA-1+3).EQ.' ') .OR.
     &              (ZK24(JREFA-1+3).EQ.'ELIML') .OR.
     &              (ZK24(JREFA-1+3).EQ.'ELIMF'))

        IF (ZK24(JREFA-1+5).EQ.' ') THEN
          CALL ASSERT(ZK24(JREFA-1+6).EQ.' ')

        ELSEIF (ZK24(JREFA-1+5).EQ.'FETI') THEN
          CALL ASSERT(ZK24(JREFA-1+6).NE.' ')

        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF

        IF (ZK24(JREFA-1+7).NE.' ') THEN
          CALL VERIJA('O','SOLVEUR',ZK24(JREFA-1+7),M80,NVU,NOBJ)
        ENDIF

        CALL ASSERT(ZK24(JREFA-1+8).EQ.' ' .OR.
     &              ZK24(JREFA-1+8).EQ.'ASSE' .OR.
     &              ZK24(JREFA-1+8).EQ.'DECT' .OR.
     &              ZK24(JREFA-1+8).EQ.'DECP')

        CALL ASSERT(ZK24(JREFA-1+9).EQ.'MS' .OR.
     &              ZK24(JREFA-1+9).EQ.'MR')

C       EXCEP1) LA MATRICE DE CONTACT DE STAT_NON_LINE
C       EST TOUJOURS LIGNE DE CIEL :
        IF (CH19.EQ.'&&OP0070.RESOC.MATR') GOTO 80

C       EXCEP2) UNE MATRICE FETI N'A PAS DE .VALM :
        IF (ZK24(JREFA-1+5).EQ.'FETI') GOTO 80

        CALL JELIRA(CH19//'.VALM','DOCU',IBID,DOCU1)
        CALL JELIRA(CH19//'.VALM','NMAXOC',I1,KBID)
        CALL ASSERT(DOCU1.EQ.' ')
        IF (ZK24(JREFA-1+9).EQ.'MS') CALL ASSERT(I1.EQ.1)
        IF (ZK24(JREFA-1+9).EQ.'MR') CALL ASSERT(I1.EQ.2)


        IF (ZK24(JREFA-1+8).EQ.' ' .OR. ZK24(JREFA-1+8).EQ.'ASSE') THEN
        ENDIF

        IF (ZK24(JREFA-1+3).EQ.' ') THEN

        ELSEIF (ZK24(JREFA-1+3).EQ.'ELIML') THEN

        ELSEIF (ZK24(JREFA-1+3).EQ.'ELIMF') THEN
        ENDIF


      ELSEIF (TYP2SD.EQ.'MATR_ASSE_GENE') THEN
C     -----------------------------------
        CH19 = NOMSD
        CALL JEEXIN(CH19//'.DESC',I1)
        IF (I1.GT.0) THEN
          CALL JEVEUO(CH19//'.DESC','L',JDESC)
C         PARFOIS .DESC EST REMPLI, PARFOIS NON :
          IF (ZI(JDESC-1+1).EQ.2) THEN
            CALL ASSERT(ZI(JDESC-1+2).GT.0)

          ELSE
            CALL ASSERT(ZI(JDESC-1+1).EQ.0)
            CALL ASSERT(ZI(JDESC-1+2).EQ.0)
            CALL ASSERT(ZI(JDESC-1+3).EQ.0)
          ENDIF
        ENDIF

        CALL JELIRA(CH19//'.REFA','DOCU',IBID,DOCU1)
        CALL ASSERT(DOCU1.EQ.' ')
        CALL JEVEUO(CH19//'.REFA','L',JREFA)
        CALL ASSERT(ZK24(JREFA-1+10).EQ.'GENE')

C       CALL VERIJA('O','????',ZK24(JREFA-1+1),M80,NVU,NOBJ)
        CALL VERIJA('O','NUME_DDL',ZK24(JREFA-1+2),M80,NVU,NOBJ)

        CALL ASSERT(ZK24(JREFA-1+3).EQ.' ')
        CALL ASSERT(ZK24(JREFA-1+4).EQ.' ')
        CALL ASSERT(ZK24(JREFA-1+5).EQ.' ')
        CALL ASSERT(ZK24(JREFA-1+6).EQ.' ')

        IF (ZK24(JREFA-1+7).NE.' ') THEN
          CALL VERIJA('O','SOLVEUR',ZK24(JREFA-1+7),M80,NVU,NOBJ)
        ENDIF

        CALL ASSERT(ZK24(JREFA-1+8).EQ.' ' .OR.
     &              ZK24(JREFA-1+8).EQ.'ASSE' .OR.
     &              ZK24(JREFA-1+8).EQ.'DECT' .OR.
     &              ZK24(JREFA-1+8).EQ.'DECP')

        CALL ASSERT(ZK24(JREFA-1+9).EQ.'MS' .OR.
     &              ZK24(JREFA-1+9).EQ.'MR')


        CALL JELIRA(CH19//'.VALM','DOCU',IBID,DOCU1)
        CALL JELIRA(CH19//'.VALM','NMAXOC',I1,KBID)
        CALL ASSERT(DOCU1.EQ.' ')
        IF (ZK24(JREFA-1+9).EQ.'MS') CALL ASSERT(I1.EQ.1)
        IF (ZK24(JREFA-1+9).EQ.'MR') CALL ASSERT(I1.EQ.2)

        IF (ZK24(JREFA-1+8).EQ.' ' .OR. ZK24(JREFA-1+8).EQ.'ASSE') THEN
        ENDIF


      ELSEIF (TYP2SD.EQ.'SOLVEUR') THEN
C     -----------------------------------
        CH19 = NOMSD
        CALL JEVEUO(CH19//'.SLVK','L',JSLVK)
        METRES = ZK24(JSLVK-1+1)
        CALL ASSERT(METRES.EQ.'FETI' .OR. METRES.EQ.'GCPC' .OR.
     &              METRES.EQ.'LDLT' .OR. METRES.EQ.'MULT_FRO' .OR.
     &              METRES.EQ.'MUMPS')



      ELSEIF (TYP2SD.EQ.'NUME_EQUA') THEN
C     -----------------------------------
        CH19 = NOMSD
        CALL VERIJA('O','PROF_CHNO',CH19,M80,NVU,NOBJ)


      ELSEIF (TYP2SD.EQ.'NUME_EQGE') THEN
C     -----------------------------------
        CH19 = NOMSD
        CALL VERIJA('O','PROF_VGEN',CH19,M80,NVU,NOBJ)


      ELSEIF (TYP2SD.EQ.'NUME_DDL') THEN
C     -----------------------------------
        CH14 = NOMSD
        CALL JEVEUO(CH14//'.NSLV','L',JNSLV)
        CALL VERIJA('O','SOLVEUR',ZK24(JNSLV),M80,NVU,NOBJ)
C       -- SI FETI, IL N'Y A PAS DE STOCKAGE :
        CALL JEVEUO(ZK24(JNSLV) (1:19)//'.SLVK','L',JSLVK)
        IF (ZK24(JSLVK).NE.'FETI') CALL VERIJA('O','STOCKAGE',CH14,M80,
     &      NVU,NOBJ)

C       IL ARRIVE (CALC_MATR_AJOU) QUE NUME_EQGE SOIT VIDE :
        CALL JEEXIN(CH14//'.NUME.REFN',IEXI)
        IF (IEXI.EQ.0) GOTO 70

        CALL JEEXIN(CH14//'.NUME.ORIG',IEXI)
        IF (IEXI.EQ.0) THEN
          CALL VERIJA('O','NUME_EQUA',CH14//'.NUME',M80,NVU,NOBJ)

        ELSE
          CALL VERIJA('O','NUME_EQGE',CH14//'.NUME',M80,NVU,NOBJ)
        ENDIF
   70   CONTINUE


      ELSEIF (TYP2SD.EQ.'STOCKAGE') THEN
C     -----------------------------------
        CH14 = NOMSD
        CALL JEEXIN(CH14//'.SMOS.SMDI',I1)
        CALL JEEXIN(CH14//'.SLCS.SCDI',I2)
        CALL JEEXIN(CH14//'.MLTF.ADNT',I3)
        CALL ASSERT(I1.GT.0)
        CALL VERIJA('O','STOC_MORSE',CH14//'.SMOS',M80,NVU,NOBJ)
        IF (I2.GT.0) CALL VERIJA('O','STOC_LCIEL',CH14//'.SLCS',M80,NVU,
     &                           NOBJ)
        IF (I3.GT.0) CALL VERIJA('O','STOC_MLTF',CH14//'.MLTF',M80,NVU,
     &                           NOBJ)


      ELSEIF (TYP2SD.EQ.'STOC_LCIEL') THEN
C     -----------------------------------
        CH19 = NOMSD

        CALL JEVEUO(CH19//'.SCDE','L',JSCDE)
        CALL ASSERT(ZI(JSCDE-1+1).GT.0)
        CALL ASSERT(ZI(JSCDE-1+2).GT.0)
        CALL ASSERT(ZI(JSCDE-1+3).GT.0)
        CALL ASSERT(ZI(JSCDE-1+4).GT.0)
        CALL ASSERT(ZI(JSCDE-1+5).EQ.0)
        CALL ASSERT(ZI(JSCDE-1+6).EQ.0)



      ELSEIF (TYP2SD.EQ.'STOC_MORSE') THEN
C     -----------------------------------
        CH19 = NOMSD

        CALL JEVEUO(CH19//'.SMDE','L',JSMDE)
        CALL ASSERT(ZI(JSMDE-1+1).GT.0)
        CALL ASSERT(ZI(JSMDE-1+2).GT.0)
        CALL ASSERT(ZI(JSMDE-1+3).EQ.1)
        CALL ASSERT(ZI(JSMDE-1+4).EQ.0)
        CALL ASSERT(ZI(JSMDE-1+5).EQ.0)
        CALL ASSERT(ZI(JSMDE-1+6).EQ.0)



      ENDIF

   80 CONTINUE
      CALL JEDEMA()
      END
