      SUBROUTINE TE0545(OPTION,NOMTE)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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

      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - FONCTION REALISEE:  CALCUL DES OPTIONS NON-LINEAIRES MECANIQUES
C                          EN 2D (CPLAN ET DPLAN) ET AXI
C                          POUR LES ELEMNTS GRAD_VARI
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................
      INTEGER    NNOMAX,NPGMAX,EPSMAX,DDLMAX
      PARAMETER (NNOMAX=27,NPGMAX=27,EPSMAX=20,DDLMAX=15*NNOMAX)
C ......................................................................
      CHARACTER*8 TYPMOD(2)
      LOGICAL RESI,RIGI,AXI
      INTEGER NNO,NNOB,NPG,NDIM,NDDL,NEPS,LGPG
      INTEGER IPOIDS,IVF,IDFDE,IVFB,IDFDEB
      INTEGER IMATE,ICONTM,IVARIM,IINSTM,IINSTP,IDEPLM,IDEPLP,ICOMPO
      INTEGER IVECTU,ICONTP,IVARIP,IMATUU,ICARCR,IVARIX,IGEOM,ICORET
      INTEGER IRET,NNOS,JGANO,JGANOB,JTAB(7)
      REAL*8  XYZ(3),UNIT(NNOMAX),ANGMAS(7)
      REAL*8  B(EPSMAX,NPGMAX,DDLMAX),W(NPGMAX),NI2LDC(EPSMAX)

      CHARACTER*32 JEXR8

C - INITIALISATION
       
      RESI = OPTION(1:9).EQ.'FULL_MECA' .OR. OPTION(1:9).EQ.'RAPH_MECA'
      RIGI = OPTION(1:9).EQ.'FULL_MECA' .OR. OPTION(1:9).EQ.'RIGI_MECA'
      
      CALL TEATTR(' ','S','TYPMOD',TYPMOD(1),IRET)
      TYPMOD(2) = 'GRADVARI'
      AXI = TYPMOD(1).EQ.'AXIS'

      CALL ELREFV(NOMTE,'RIGI',NDIM,NNO,NNOB,NNOS,NPG,IPOIDS,IVF,
     &              IVFB,IDFDE,IDFDEB,JGANO,JGANOB)


C - PARAMETRES EN ENTREE

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PCONTMR','L',ICONTM)
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PDEPLMR','L',IDEPLM)
      CALL JEVECH('PDEPLPR','L',IDEPLP)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL JEVECH('PCARCRI','L',ICARCR)
      CALL JEVECH('PINSTMR','L',IINSTM)
      CALL JEVECH('PINSTPR','L',IINSTP)


C - PARAMETRES EN SORTIE

      IF (RIGI) THEN
        CALL JEVECH('PMATUNS','E',IMATUU)
      END IF
      
      IF (RESI) THEN
        CALL JEVECH('PVECTUR','E',IVECTU)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVARIPR','E',IVARIP)
        CALL JEVECH('PCODRET','E',ICORET)
      END IF


C    NOMBRE DE VARIABLES INTERNES
      CALL TECACH('OON','PVARIMR',7,JTAB,IRET)
      LGPG = MAX(JTAB(6),1)*JTAB(7)


C    ESTIMATION VARIABLES INTERNES A L'ITERATION PRECEDENTE
      IF (RESI) THEN
        CALL JEVECH('PVARIMP','L',IVARIX)
        CALL DCOPY(NPG*LGPG,ZR(IVARIX),1,ZR(IVARIP),1)
      END IF


C    BARYCENTRE ET ORIENTATION DU MASSIF
      CALL R8INIR(NNO,1.D0/NNO,UNIT,1)
      CALL DGEMV('N',NDIM,NNO,1.D0,ZR(IGEOM),NDIM,UNIT,1,0.D0,XYZ,1)
      CALL RCANGM ( NDIM, XYZ, ANGMAS )


C - CALCUL DES ELEMENTS CINEMATIQUES

      CALL NMGVMB(NDIM,NNO,NNOB,NPG,AXI,ZR(IGEOM),ZR(IVF),ZR(IVFB),
     &            IDFDE,IDFDEB,IPOIDS,NDDL,NEPS,B,W,NI2LDC)
     


C - CALCUL DES FORCES INTERIEURES ET MATRICES TANGENTES

      CALL NGFINT(OPTION,TYPMOD,NDIM,NDDL,NEPS,NPG,W,B,ZK16(ICOMPO),
     &            'RIGI',ZI(IMATE),ANGMAS,LGPG,ZR(ICARCR),ZR(IINSTM),
     &            ZR(IINSTP),ZR(IDEPLM),ZR(IDEPLP),NI2LDC,ZR(ICONTM),
     &            ZR(IVARIM),ZR(ICONTP),ZR(IVARIP),ZR(IVECTU),
     &            ZR(IMATUU),ZI(ICORET))
      
      END
