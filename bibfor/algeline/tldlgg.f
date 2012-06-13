      SUBROUTINE TLDLGG(ISTOP,LMAT,ILDEB,ILFIN,NDIGIT,NDECI,ISINGU,
     &                  NPVNEG,IRET)
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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


      INCLUDE 'jeveux.h'
      CHARACTER*8 RENUM
      CHARACTER*16 METRES
      CHARACTER*19 NOMA19,SOLVEU
      INTEGER IBID,ISTOP,LMAT,ILDEB,ILFIN,NDIGIT
      INTEGER NDECI,ISINGU,NPVNEG,IRET

C     ------------------------------------------------------------------
      CALL UTTCPU('CPU.RESO.1','DEBUT',' ')
      CALL UTTCPU('CPU.RESO.4','DEBUT',' ')

      NOMA19 = ZK24(ZI(LMAT+1))
      CALL DISMOI('F','METH_RESO',NOMA19,'MATR_ASSE',IBID,METRES,IBID)
      CALL ASSERT(METRES.EQ.'LDLT'.OR.METRES.EQ.'MULT_FRONT'.OR.
     &            METRES.EQ.'MUMPS')
      CALL DISMOI('F','RENUM_RESO',NOMA19,'MATR_ASSE',IBID,RENUM,IBID)
C     -- ON MET SCIEMMENT CETTE VALEUR CAR ON NE CONNAIT PAS A CET
C        ENDROIT LA SD SOLVEUR LIE A L'OPERATEUR (ELLE PEUT DIFFERER
C        DE CELLE LIEE AUX MATRICES). BESOIN UNIQUEMENT POUR MUMPS.
      SOLVEU=' '
      CALL TLDLG3(METRES,RENUM,ISTOP,LMAT,ILDEB,ILFIN,NDIGIT,NDECI,
     &            ISINGU,NPVNEG,IRET,SOLVEU)

      CALL UTTCPU('CPU.RESO.1','FIN',' ')
      CALL UTTCPU('CPU.RESO.4','FIN',' ')
      END
