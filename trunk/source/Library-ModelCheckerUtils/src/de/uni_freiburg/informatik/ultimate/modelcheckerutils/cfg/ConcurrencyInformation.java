/*
 * Copyright (C) 2018 Matthias Heizmann (heizmann@informatik.uni-freiburg.de)
 * Copyright (C) 2018 Daniel Dietsch (dietsch@informatik.uni-freiburg.de)
 * Copyright (C) 2018 University of Freiburg
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

package de.uni_freiburg.informatik.ultimate.modelcheckerutils.cfg;

import java.util.Collection;
import java.util.Map;

import de.uni_freiburg.informatik.ultimate.modelcheckerutils.cfg.structure.IIcfgForkTransitionThreadCurrent;
import de.uni_freiburg.informatik.ultimate.modelcheckerutils.cfg.structure.IIcfgJoinTransitionThreadCurrent;
import de.uni_freiburg.informatik.ultimate.modelcheckerutils.cfg.structure.IcfgLocation;

/**
 *
 * @author Matthias Heizmann (heizmann@informatik.uni-freiburg.de)
 *
 */
public class ConcurrencyInformation {

	private final Map<IIcfgForkTransitionThreadCurrent<IcfgLocation>, ThreadInstance> mThreadInstanceMap;
	private final Collection<IIcfgJoinTransitionThreadCurrent<IcfgLocation>> mJoinTransitions;

	public ConcurrencyInformation(
			final Map<IIcfgForkTransitionThreadCurrent<IcfgLocation>, ThreadInstance> threadInstanceMap,
			final Collection<IIcfgJoinTransitionThreadCurrent<IcfgLocation>> joinTransitions) {
		mThreadInstanceMap = threadInstanceMap;
		mJoinTransitions = joinTransitions;
	}

	/**
	 * Map is empty if program is not a concurrent program.
	 */
	public Map<IIcfgForkTransitionThreadCurrent<IcfgLocation>, ThreadInstance> getThreadInstanceMap() {
		return mThreadInstanceMap;
	}

	public Collection<IIcfgJoinTransitionThreadCurrent<IcfgLocation>> getJoinTransitions() {
		return mJoinTransitions;
	}



}
