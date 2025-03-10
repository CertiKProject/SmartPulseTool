/*
 * Copyright (C) 2015 Daniel Dietsch (dietsch@informatik.uni-freiburg.de)
 * Copyright (C) 2015 Marius Greitschus (greitsch@informatik.uni-freiburg.de)
 * Copyright (C) 2015 University of Freiburg
 *
 * This file is part of the ULTIMATE AbstractInterpretationV2 plug-in.
 *
 * The ULTIMATE AbstractInterpretationV2 plug-in is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The ULTIMATE AbstractInterpretationV2 plug-in is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with the ULTIMATE AbstractInterpretationV2 plug-in. If not, see <http://www.gnu.org/licenses/>.
 *
 * Additional permission under GNU GPL version 3 section 7:
 * If you modify the ULTIMATE AbstractInterpretationV2 plug-in, or any covered work, by linking
 * or combining it with Eclipse RCP (or a modified version of Eclipse RCP),
 * containing parts covered by the terms of the Eclipse Public License, the
 * licensors of the ULTIMATE AbstractInterpretationV2 plug-in grant you additional permission
 * to convey the resulting work.
 */

package de.uni_freiburg.informatik.ultimate.plugins.analysis.abstractinterpretationv2.domain.nonrelational.evaluator;

import de.uni_freiburg.informatik.ultimate.modelcheckerutils.absint.IAbstractState;
import de.uni_freiburg.informatik.ultimate.plugins.analysis.abstractinterpretationv2.domain.nonrelational.INonrelationalValue;
import de.uni_freiburg.informatik.ultimate.plugins.analysis.abstractinterpretationv2.domain.nonrelational.INonrelationalValueFactory;

/**
 * Abstract class for NAry evaluators that have some operator.
 *
 * @author Marius Greitschus (greitsch@informatik.uni-freiburg.de)
 */
public abstract class NAryEvaluator<VALUE extends INonrelationalValue<VALUE>, STATE extends IAbstractState<STATE>>
		extends Evaluator<VALUE, STATE> {

	public NAryEvaluator(final int maxRecursionDepth, final INonrelationalValueFactory<VALUE> nonrelationalValueFactory,
			final EvaluatorLogger logger) {
		super(maxRecursionDepth, nonrelationalValueFactory, logger);
	}

	/**
	 * Sets the operator of the evaluator. Note that for some evaluators, the operator cannot be set.
	 *
	 * @param operator
	 *            The operator to set.
	 */
	public abstract void setOperator(Object operator);

	/**
	 * Returns the arity of the evaluator.
	 *
	 * @return An integer corresponding to the arity of the evaluator.
	 */
	public abstract int getArity();
}
