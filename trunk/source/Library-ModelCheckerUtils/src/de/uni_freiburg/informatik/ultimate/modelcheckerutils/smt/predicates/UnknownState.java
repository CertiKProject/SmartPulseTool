/*
 * Copyright (C) 2011-2015 Matthias Heizmann (heizmann@informatik.uni-freiburg.de)
 * Copyright (C) 2015 University of Freiburg
 *
 * This file is part of the ULTIMATE ModelCheckerUtils Library.
 *
 * The ULTIMATE ModelCheckerUtils Library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The ULTIMATE ModelCheckerUtils Library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with the ULTIMATE ModelCheckerUtils Library. If not, see <http://www.gnu.org/licenses/>.
 *
 * Additional permission under GNU GPL version 3 section 7:
 * If you modify the ULTIMATE ModelCheckerUtils Library, or any covered work, by linking
 * or combining it with Eclipse RCP (or a modified version of Eclipse RCP),
 * containing parts covered by the terms of the Eclipse Public License, the
 * licensors of the ULTIMATE ModelCheckerUtils Library grant you additional permission
 * to convey the resulting work.
 */
package de.uni_freiburg.informatik.ultimate.modelcheckerutils.smt.predicates;

import java.util.Set;

import de.uni_freiburg.informatik.ultimate.logic.Term;
import de.uni_freiburg.informatik.ultimate.modelcheckerutils.cfg.structure.IcfgLocation;
import de.uni_freiburg.informatik.ultimate.modelcheckerutils.cfg.variables.IProgramVar;

public class UnknownState implements ISLPredicate {

	private final IcfgLocation mProgramPoint;
	private final int mSerialNumber;
	private final Term mTerm;

	protected UnknownState(final IcfgLocation programPoint, final int serialNumber, final Term term) {
		mProgramPoint = programPoint;
		mSerialNumber = serialNumber;
		mTerm = term;

	}

	@Override
	public String toString() {
		String result = mSerialNumber + "#";
		if (mProgramPoint != null) {
			result += mProgramPoint.getDebugIdentifier();
		} else {
			result += "unknown";
		}
		return result;
	}

	@Override
	public int hashCode() {
		return mSerialNumber;
	}

	@Override
	public IcfgLocation getProgramPoint() {
		return mProgramPoint;
	}

	@Override
	public Term getFormula() {
		return mTerm;
	}

	@Override
	public Set<IProgramVar> getVars() {
		throw new UnsupportedOperationException();
	}

	@Override
	public String[] getProcedures() {
		throw new UnsupportedOperationException();
	}

	@Override
	public Term getClosedFormula() {
		throw new UnsupportedOperationException();
	}
}
