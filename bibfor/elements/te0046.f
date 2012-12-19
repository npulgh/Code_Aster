      SUBROUTINE TE0046(OPTION,NOMTE)
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'
      CHARACTER*16 OPTION,NOMTE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE GENIAUT S.GENIAUT

C.......................................................................
C
C     BUT: CALCUL DES COORDONNEES DES POINTS DE GAUSS
C          DE LA FAMILLE X-FEM (POINTS DE GAUSS DES SOUS-�L�MENTS)
C          DANS L'ESPACE DE L'ELEMENT PARENT DE REFERENCE
C
C          OPTIONS : 'XFEM_XPG'
C
C  ENTREES  ---> OPTION : OPTION DE CALCUL
C           ---> NOMTE  : NOM DU TYPE ELEMENT
C
C.......................................................................


C      CHARACTER*8   ELREF,FPG,ELC,NOMPAR(4)
C      INTEGER NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO
C      INTEGER NFH,NFE,SINGU,DDLC,DDLS,NDDL
C      INTEGER IGEOM,IPRES,ITEMPS,IFORC,IRET,IRES
C      INTEGER JLST,JPTINT,JAINT,JCFACE,JLONCH
C      INTEGER I,J,NINTER,NFACE,CFACE(5,3),IFA,NLI,IN(3),IG
C      INTEGER AR(12,3),NBAR,FAC(6,4),NBF,IBID2(12,3),IBID,INO,ILEV
C      INTEGER NNOF,NPGF,IPOIDF,IVFF,IDFDEF,IPGF,POS
C      REAL*8  MULT,PRES,CISA, FORREP(3,2),FF(27),G(3),JAC,ND(3),HE(2)
C      REAL*8  RR(2),LST,XG(4)
C      DATA    HE / -1.D0 , 1.D0/

      CHARACTER*8  ELREFP,ELRESE(6),FAMI(6),ENR
      REAL*8  XG(3),XE(3),FF(27),RBID,COORSE(81)
      INTEGER IBID,NDIM,NNOP,NNO,NPG,IVF
      INTEGER NFH,NFE,SINGU,DDLC,JPMILT,IRESE
      INTEGER JPINTT,JCNSET,JHEAVT,JLONCH,IGEOM,JOUT
      INTEGER I,J,NSE,ISE,IN,INO,IPG,KPG
      LOGICAL ISELLI,LTEATT, AXI

      DATA    ELRESE /'SE2','TR3','TE4','SE3','TR6','TE4'/
      DATA    FAMI   /'BID','XINT','XINT','BID','XINT','XINT'/

      CALL JEMARQ()
C
C-----------------------------------------------------------------------
C     INITIALISATIONS
C-----------------------------------------------------------------------

C     ELEMENT DE REFERENCE PARENT : RECUP DE NDIM ET NNOP
      CALL ELREF1(ELREFP)
      CALL ELREF4(' ','RIGI',NDIM,NNOP,IBID,IBID,IBID,IBID,IBID,IBID)

      AXI = LTEATT(' ','AXIS','OUI')

C     SOUS-ELEMENT DE REFERENCE : RECUP DE NNO, NPG ET IVF
      IF (.NOT.ISELLI(ELREFP).AND. NDIM.LE.2) THEN
        IRESE=3
      ELSE
        IRESE=0
      ENDIF
      CALL ELREF4(ELRESE(NDIM+IRESE),FAMI(NDIM+IRESE),IBID,NNO,IBID,
     &                                        NPG,IBID,IVF,IBID,IBID)

C     INITIALISATION DES DIMENSIONS DES DDLS X-FEM
      CALL XTEINI(NOMTE,NFH,NFE,SINGU,DDLC,IBID,IBID,IBID,
     &              IBID,IBID,IBID)

C-----------------------------------------------------------------------
C     RECUPERATION DES ENTREES / SORTIE
C-----------------------------------------------------------------------

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PPINTTO','L',JPINTT)
      CALL JEVECH('PCNSETO','L',JCNSET)
      CALL JEVECH('PHEAVTO','L',JHEAVT)
      CALL JEVECH('PLONCHA','L',JLONCH)
C     PROPRES AUX ELEMENTS 1D ET 2D (QUADRATIQUES)
      CALL TEATTR (NOMTE,'S','XFEM',ENR,IBID)
      IF ((IBID.EQ.0).AND.(NOMTE(3:4).NE.'AX').AND.(ENR.EQ.'XH'
     & .OR.ENR.EQ.'XHT'.OR.ENR.EQ.'XT'.OR.ENR.EQ.'XHC').AND. NDIM.LE.2)
     &  CALL JEVECH('PPMILTO','L',JPMILT)

      CALL JEVECH('PXFGEOM','E',JOUT)

C     R�CUP�RATION DE LA SUBDIVISION DE L'�L�MENT EN NSE SOUS ELEMENT
      NSE=ZI(JLONCH-1+1)

C       BOUCLE D'INTEGRATION SUR LES NSE SOUS-ELEMENTS
      DO 110 ISE=1,NSE

C       BOUCLE SUR LES SOMMETS DU SOUS-TRIA (DU SOUS-SEG)
        DO 111 IN=1,NNO
          INO=ZI(JCNSET-1+NNO*(ISE-1)+IN)
          DO 112 J=1,NDIM
            IF (INO.LT.1000) THEN
              COORSE(NDIM*(IN-1)+J)=ZR(IGEOM-1+NDIM*(INO-1)+J)
            ELSEIF (INO.GT.1000 .AND. INO.LT.2000) THEN
              COORSE(NDIM*(IN-1)+J)=ZR(JPINTT-1+NDIM*(INO-1000-1)+J)
            ELSEIF (INO.GT.2000 .AND. INO.LT.3000) THEN
              COORSE(NDIM*(IN-1)+J)=ZR(JPMILT-1+NDIM*(INO-2000-1)+J)
           ELSEIF (INO.GT.3000) THEN
              COORSE(NDIM*(IN-1)+J)=ZR(JPMILT-1+NDIM*(INO-3000-1)+J)
            ENDIF
 112      CONTINUE
 111    CONTINUE


C-----------------------------------------------------------------------
C         BOUCLE SUR LES POINTS DE GAUSS DU SOUS-ELT
C-----------------------------------------------------------------------

        DO 200 KPG=1,NPG

C         COORDONN�ES DU PT DE GAUSS DANS LE REP�RE R�EL : XG
          CALL VECINI(NDIM,0.D0,XG)
          DO 210 I=1,NDIM
            DO 211 IN=1,NNO
              XG(I) = XG(I) + ZR(IVF-1+NNO*(KPG-1)+IN)
     &                      * COORSE(NDIM*(IN-1)+I)
 211        CONTINUE
 210      CONTINUE

C         COORDONNEES DU PG DANS L'ELEMENT DE REF PARENT : XE
          CALL REEREF(ELREFP,AXI, NNOP,IBID,ZR(IGEOM),XG,1,.FALSE.,
     &         NDIM,RBID,RBID,RBID,
     &         IBID,IBID,IBID,IBID,IBID,IBID,RBID,RBID,
     &         'NON',XE,FF,RBID,RBID,RBID,RBID)

C         NUMERO DE CE POINT DE GAUSS DANS LA FAMILLE 'XFEM'
          IPG= (ISE-1) * NPG + KPG

          DO 220 J=1,NDIM
            ZR(JOUT-1+NDIM*(IPG-1)+J) = XE(J)
 220      CONTINUE


 200    CONTINUE

C-----------------------------------------------------------------------
C         FIN DE LA BOUCLE SUR LES POINTS DE GAUSS DU SOUS-ELT
C-----------------------------------------------------------------------


 110  CONTINUE


      CALL JEDEMA()
      END
